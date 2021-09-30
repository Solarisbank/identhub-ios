//
//  APIClient.swift
//  IdentHubSDK
//

import Foundation

protocol APIClient: AnyObject {

    func execute<DataType: Decodable>(
        request: Request,
        answerType: DataType.Type,
        completion: @escaping (Result<DataType, APIError>) -> Void
    )

    func download(
        request: Request,
        completion: @escaping (Result<URL?, APIError>) -> Void
    )
}

final class DefaultAPIClient: APIClient {

    // MARK: Private properties

    private let defaultUrlSession = URLSession(configuration: .default)

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
        completion: @escaping (Result<DataType, APIError>) -> Void
    ) {
        do {
            let urlRequest = try request.asURLRequest()

            let task = defaultUrlSession.dataTask(with: urlRequest) { [weak self] data, urlResponse, error in
                if error != nil {
                    completion(.failure(.unknownError))
                }

                if let self = self,
                   let response = urlResponse as? HTTPURLResponse,
                   let data = data {
                    completion(self.mapResponse(response: response, data: data))
                }
            }
            task.resume()
        } catch {
            completion(.failure(.requestError))
        }
    }

    /// Executes download url request.
    ///
    /// - Parameters:
    ///   - request: request to be performed.
    ///   - completion: the completion handler with the response.
    func download(
        request: Request,
        completion: @escaping (Result<URL?, APIError>) -> Void
    ) {
        do {
            let urlRequest = try request.asURLRequest()

            let task = defaultUrlSession.downloadTask(with: urlRequest) { location, response, error in
                if error != nil {
                    completion(.failure(.unknownError))
                }
                completion(.success(location))
            }
            task.resume()
        } catch {
            completion(.failure(.requestError))
        }
    }

    // MARK: Private methods

    private func mapResponse<DataType: Decodable>(response: HTTPURLResponse, data: Data) -> Result<DataType, APIError> {
        let decoder = JSONDecoder()

        switch response.statusCode {
        case 200:
            decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)

            do {
                let decodedData = try decoder.decode(DataType.self, from: data)
                return .success(decodedData)
            } catch let error {
                print("Error with encoding data: \(error.localizedDescription)")
                return .failure(.malformedResponseJson)
            }
        case 400:
            let error = obtainErrorData(data: data)
            return .failure(.clientError(error: error))
        case 401:
            return .failure(.authorizationFailed)
        case 403:
            return .failure(.unauthorizedAction)
        case 404:
            return .failure(.resourceNotFound)
        case 409:
            return .failure(.expectationMismatch)
        case 412:
            let error = obtainErrorData(data: data)
            return .failure(.incorrectIdentificationStatus(error: error))
        case 422:
            return .failure(.unprocessableEntity)
        case 500:
            return .failure(.internalServerError)
        default:
            return .failure(.unknownError)
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
