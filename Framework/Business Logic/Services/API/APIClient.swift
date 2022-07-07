//
//  APIClient.swift
//  IdentHubSDK
//

import Foundation

// Max request retry count
let maxRetries = 3
// Retry timeout
let retryTimeout = 5

fileprivate let apiLog = SBLog.standard.withCategory(.api)

protocol APIClient: AnyObject {

    func execute<DataType: Decodable>(
        request: Request,
        answerType: DataType.Type,
        completion: @escaping (Result<DataType, ResponseError>) -> Void
    )

    func download(
        request: Request,
        completion: @escaping (Result<URL?, ResponseError>) -> Void
    )
}

final class DefaultAPIClient: APIClient {

    // MARK: Private properties

    private let defaultUrlSession = URLSession(configuration: .default)
    private var retryCount = 0
    
    /// Attribute specifies if published request with nil result object can be retried
    private var isCanRetryRequest: Bool {
        retryCount += 1
        return retryCount < maxRetries
    }

    // MARK: Methods

    /// Executes url request.
    ///
    /// - Parameters:
    ///   - request: request to be performed.
    ///   - dataType: data type of the response.
    ///   - completion: the completion handler with the response.
    func execute<DataType: Decodable>(
        request: Request,
        answerType: DataType.Type,
        completion: @escaping (Result<DataType, ResponseError>) -> Void
    ) {
        do {
            let urlRequest = try request.asURLRequest()

            log(urlRequest)

            let task = defaultUrlSession.dataTask(with: urlRequest) { [weak self] data, urlResponse, error in
                
                log(response: urlResponse as? HTTPURLResponse, error: error, data: data)

                if error != nil {
                    completeWithResult(.failure(ResponseError(.unknownError, urlResponse as? HTTPURLResponse)), completion: completion)
                }

                if let self = self,
                   let response = urlResponse as? HTTPURLResponse,
                   let data = data {
                    guard let result: Result<DataType, ResponseError> = self.mapResponse(response: response, data: data) else {
                        if self.isCanRetryRequest {
                            DispatchQueue.main.asyncAfter(deadline: retryTimeout.seconds.fromNow) {
                                apiLog.debug("Retrying request")
                                self.execute(request: request, answerType: answerType, completion: completion)
                            }
                        } else {
                            completeWithResult(.failure(ResponseError(.unknownError, urlResponse as? HTTPURLResponse)), completion: completion)
                            self.retryCount = 0
                        }
                        return
                    }
                    completeWithResult(result, completion: completion)
                    self.retryCount = 0
                }
            }
            task.resume()
        } catch {
            completeWithResult(.failure(ResponseError(.unknownError)), completion: completion)
        }
    }

    /// Executes download url request.
    ///
    /// - Parameters:
    ///   - request: request to be performed.
    ///   - completion: the completion handler with the response.
    func download(
        request: Request,
        completion: @escaping (Result<URL?, ResponseError>) -> Void
    ) {
        do {
            let urlRequest = try request.asURLRequest()

            let task = defaultUrlSession.downloadTask(with: urlRequest) { location, response, error in
                log(response: response as? HTTPURLResponse, error: error)

                var result: Result<URL?, ResponseError>
                if error != nil {
                    result = .failure(ResponseError(.unknownError, response as? HTTPURLResponse))
                } else {
                    result = .success(location)
                }
                completeWithResult(result, completion: completion)
            }
            task.resume()
        } catch {
            completeWithResult(.failure(ResponseError(.unknownError)), completion: completion)
        }
    }

    // MARK: Private methods
    
    /// Method mapped server response object from data by generic model type
    /// - Returns: - returns optional result because for error code 502 and 503 object is nil
    private func mapResponse<DataType: Decodable>(response: HTTPURLResponse, data: Data) -> Result<DataType, ResponseError>? {
        let decoder = JSONDecoder()
        var result: Result<DataType, ResponseError>?
        
        switch response.statusCode {
        case 200:
            decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
            do {
                let decodedData = try decoder.decode(DataType.self, from: data)
                result = .success(decodedData)
            } catch let error {
                apiLog.error("Error while trying to decode \(DataType.self) response: \(error.logDescription)")
                let responseError = ResponseError(.malformedResponseJson, response)
                result = .failure(responseError)
            }
        case 400:
            let errorDetail = obtainErrorData(data: data)
            let responseError = ResponseError(.clientError(error: errorDetail), response)
            result = .failure(responseError)
        case 401:
            let responseError = ResponseError(.authorizationFailed, response)
            result = .failure(responseError)
        case 403:
            let responseError = ResponseError(.unauthorizedAction, response)
            result = .failure(responseError)
        case 404:
            let responseError = ResponseError(.resourceNotFound, response)
            result = .failure(responseError)
        case 409:
            let responseError = ResponseError(.expectationMismatch, response)
            result = .failure(responseError)
        case 412:
            let errorDetail = obtainErrorData(data: data)
            let responseError = ResponseError(.incorrectIdentificationStatus(error: errorDetail), response)
            result = .failure(responseError)
        case 422:
            let responseError = ResponseError(.unprocessableEntity, response)
            result = .failure(responseError)
        case 500:
            let responseError = ResponseError(.internalServerError, response)
            result = .failure(responseError)
        case 502,
             503:
            result = nil
        case 1001...3999:
            let errorDetail = obtainErrorData(data: data)
            let responseError = ResponseError(.identificationDataInvalid(error: errorDetail), response)
            result = .failure(responseError)
        case 4000...5000:
            let errorDetail = obtainErrorData(data: data)
            let responseError = ResponseError(.fraudData(error: errorDetail), response)
            result = .failure(responseError)
        default:
            let responseError = ResponseError(.unknownError, response)
            result = .failure(responseError)
        }
        
        return result
    }

    private func obtainErrorData(data: Data) -> ErrorDetail? {

        let decoder = JSONDecoder()

        do {
            let decodedData = try decoder.decode(ErrorDetail.self, from: data)
            return decodedData
        } catch let error {
            apiLog.error("Error while trying to decode ErrorDetail response: \(error.logDescription)")
        }
        return nil
    }
    
}

// MARK: - Logging Helpers

/// Convenience wrapper to avoid having to introduce typed variables for result to both log and return in completion.
internal func completeWithResult<T, U>(_ result: Result<T, U>, completion: (Result<T, U>) -> Void) {
    log(result)
    completion(result)
}

/// Log an API request.
fileprivate func log(_ request: URLRequest) {
    let urlString = request.url?.absoluteString ?? "<URL undefined>"
    apiLog.info("\(request.httpMethod ?? "") \(urlString)")
    if let body = request.httpBody, let payload = String(data: body, encoding: .utf8) {
        apiLog.debug("Request payload: \(payload)")
    }
}

/// Log the result of an API request.
fileprivate func log(response: HTTPURLResponse?, error: Error?, data: Data? = nil) {
    let urlString = response?.url?.absoluteString ?? "<URL undefined>"
    if let error = error {
        apiLog.warn("Error while accessing \(urlString): \(error.localizedDescription) (\(response?.description ?? "<no response>")")
    } else {
        apiLog.info("HTTP \(response?.statusCode ?? -1) for \(urlString) [request-id: \(response?.allHeaderFields["x-request-id"] ?? "-")]")
        if let body = data, let payload = String(data: body, encoding: .utf8) {
            apiLog.debug("Response payload: \(payload)")
        }
    }
}

/// Log an API-related result.
fileprivate func log<T, U: Error>(_ result: Result<T, U>?) {
    if let result = result {
        switch result {
        case .failure: apiLog.warn("Returned failure result: \(result.logDescription)")
        case .success: apiLog.debug("Returned success result: \(result.logDescription)")
        }
    } else {
        apiLog.debug("Returned result: <nil>")
    }
}

extension Error {
    var logDescription: String {
        switch self {
        case let error as ResponseError:
            return error.description
        default:
            return String(describing: self)
        }
    }
}

extension Result {
    /// Provide a text representation of the result suitable for logging.
    var logDescription: String {
        switch self {
        case .failure(let error):
            return error.logDescription
        case .success(let success):
            return String(describing: type(of: success))
        }
    }
}
