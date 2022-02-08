//
//  APIClient.swift
//  IdentHubSDK
//

import Foundation

// Max request retry count
let maxRetries = 3
// Retry timeout
let retryTimeout = 5

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

            let task = defaultUrlSession.dataTask(with: urlRequest) { [weak self] data, urlResponse, error in
                if error != nil {
                    completion(.failure(ResponseError(.unknownError, urlResponse as? HTTPURLResponse)))
                }

                if let self = self,
                   let response = urlResponse as? HTTPURLResponse,
                   let data = data {
                    guard let result: Result<DataType, ResponseError> = self.mapResponse(response: response, data: data) else {
                        if self.isCanRetryRequest {
                            DispatchQueue.main.asyncAfter(deadline: retryTimeout.seconds.fromNow) {
                                self.execute(request: request, answerType: answerType, completion: completion)
                            }
                        } else {
                            completion(.failure(ResponseError(.unknownError, urlResponse as? HTTPURLResponse)))
                            self.retryCount = 0
                        }
                        return
                    }
                    
                    completion(result)
                    self.retryCount = 0
                }
            }
            task.resume()
        } catch {
            completion(.failure(ResponseError(.unknownError)))
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
                if error != nil {
                    completion(.failure(ResponseError(.unknownError, response as? HTTPURLResponse)))
                }
                completion(.success(location))
            }
            task.resume()
        } catch {
            completion(.failure(ResponseError(.unknownError)))
        }
    }

    // MARK: Private methods
    
    /// Method mapped server response object from data by generic model type
    /// - Returns: - returns optional result because for error code 502 and 503 object is nil
    private func mapResponse<DataType: Decodable>(response: HTTPURLResponse, data: Data) -> Result<DataType, ResponseError>? {
        let decoder = JSONDecoder()

        switch response.statusCode {
        case 200:
            decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)

            do {
                let decodedData = try decoder.decode(DataType.self, from: data)
                return .success(decodedData)
            } catch let error {
                print("Error with encoding data: \(error.localizedDescription)")
                let responseError = ResponseError(.malformedResponseJson, response)
                return .failure(responseError)
            }
        case 400:
            let errorDetail = obtainErrorData(data: data)
            let responseError = ResponseError(.clientError(error: errorDetail), response)
            return .failure(responseError)
        case 401:
            let responseError = ResponseError(.authorizationFailed, response)
            return .failure(responseError)
        case 403:
            let responseError = ResponseError(.unauthorizedAction, response)
            return .failure(responseError)
        case 404:
            let responseError = ResponseError(.resourceNotFound, response)
            return .failure(responseError)
        case 409:
            let responseError = ResponseError(.expectationMismatch, response)
            return .failure(responseError)
        case 412:
            let errorDetail = obtainErrorData(data: data)
            let responseError = ResponseError(.incorrectIdentificationStatus(error: errorDetail), response)
            return .failure(responseError)
        case 422:
            let responseError = ResponseError(.unprocessableEntity, response)
            return .failure(responseError)
        case 500:
            let responseError = ResponseError(.internalServerError, response)
            return .failure(responseError)
        case 502,
             503:
            return nil
        case 1001...3999:
            let errorDetail = obtainErrorData(data: data)
            let responseError = ResponseError(.identificationDataInvalid(error: errorDetail), response)
            return .failure(responseError)
        case 4000...5000:
            let errorDetail = obtainErrorData(data: data)
            let responseError = ResponseError(.fraudData(error: errorDetail), response)
            return .failure(responseError)
        default:
            let responseError = ResponseError(.unknownError, response)
            return .failure(responseError)
        }
    }

    private func obtainErrorData(data: Data) -> ErrorDetail? {

        let decoder = JSONDecoder()

        do {
            let decodedData = try decoder.decode(ErrorDetail.self, from: data)
            return decodedData
        } catch let error {
            print("Error with encoding error data: \(error.localizedDescription)")
            return nil
        }
    }
}
