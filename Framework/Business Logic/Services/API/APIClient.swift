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
        let urlRequest = request.asURLRequest()
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
        let urlRequest = request.asURLRequest()
        let task = defaultUrlSession.downloadTask(with: urlRequest) { location, response, error in
            if error != nil {
                completion(.failure(.unknownError))
            }
            completion(.success(location))
        }
        task.resume()
    }

    // MARK: Private methods

    private func mapResponse<DataType: Decodable>(response: HTTPURLResponse, data: Data) -> Result<DataType, APIError> {
        switch response.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
            if let decodedData = try? decoder.decode(DataType.self, from: data) {
                return .success(decodedData)
            } else {
                return .failure(.malformedResponseJson)
            }
        case 400:
            return .failure(.clientError)
        case 401:
            return .failure(.authorizationFailed)
        case 403:
            return .failure(.unauthorizedAction)
        case 404:
            return .failure(.resourceNotFound)
        case 409:
            return .failure(.expectationMismatch)
        case 412:
            return .failure(.incorrectIdentificationStatus)
        case 422:
            return .failure(.unprocessableEntity)
        case 500:
            return .failure(.internalServerError)
        default:
            return .failure(.unknownError)
        }
    }
}
