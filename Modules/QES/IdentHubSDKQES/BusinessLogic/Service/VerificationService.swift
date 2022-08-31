//
//  VerificationService.swift
//  IdentHubSDKQES
//
import Foundation
import IdentHubSDKCore

internal protocol VerificationService {
    /// Get indentification.
    ///
    /// - Parameter completionHandler: Response back if the verification was successful.
    func getIdentification(
        for identificationUID: String,
        completionHandler: @escaping (Result<Identification, ResponseError>) -> Void
    )

    /// Download and save document.
    ///
    /// - Parameters:
    ///     - documentId: Id of the document resource.
    ///     - completionHandler: Response back with the document or error.
    func downloadAndSaveDocument(
        withId id: String,
        completion: @escaping (Result<URL, FileStorageError>) -> Void
    )

    /// Confirm the TAN while signing the documents.
    ///
    /// - Parameters:
    ///     - token: Code sent for the given phone number.
    ///     - completionHandler: Response back if the verification was successful.
    func verifyDocumentsTAN(
        identificationUID: String,
        token: String,
        completionHandler: @escaping (Result<Identification, ResponseError>) -> Void
    )

    /// Authorize signing the documents and send sms with a TAN.
    ///
    /// - Parameter completionHandler: Response back if the verification was successful.
    func authorizeDocuments(
        identificationUID: String,
        completionHandler: @escaping (Result<Identification, ResponseError>) -> Void
    )
    
    /// Get mobile number.
    /// - Parameter completionHandler: Response back with mobile number or error.
    func getMobileNumber(completionHandler: @escaping (Result<MobileNumber, ResponseError>) -> Void)
}

internal struct VerificationServiceImpl: VerificationService {
    let apiClient: APIClient
    let fileStorage: FileStorage
    
    init(apiClient: APIClient, fileStorage: FileStorage) {
        self.apiClient = apiClient
        self.fileStorage = fileStorage
    }

    func getIdentification(for identificationUID: String, completionHandler: @escaping (Result<Identification, ResponseError>) -> Void) {
        do {
            let request = try IdentificationRequest(identificationUID: identificationUID)
            apiClient.execute(request: request, answerType: Identification.self) { result in
                completionHandler(result)
            }
        } catch {
            completionHandler(.failure(ResponseError(.requestError)))
        }
    }
    
    func downloadAndSaveDocument(withId id: String, completion: @escaping (Result<URL, FileStorageError>) -> Void) {
        getDocument(withId: id) { result in
            result
                .onSuccess { url in
                    guard let url = url else {
                        completion(.failure(.fileDownloadError(APIError.resourceNotFound)))
                        
                        return
                    }
                    
                    fileStorage.write(url: url, asFile: url.lastPathComponent + ".pdf") { result in
                        completion(result)
                    }
                }
                .onFailure { error in
                    completion(.failure(.fileDownloadError(error)))
                }
        }
    }
    
    func verifyDocumentsTAN(
        identificationUID: String,
        token: String,
        completionHandler: @escaping (Result<Identification, ResponseError>) -> Void
    ) {

        do {
            let request = try DocumentsTANRequest(identificationUID: identificationUID, token: token)
            apiClient.execute(request: request, answerType: Identification.self) { result in
                completionHandler(result)
            }
        } catch {
            completionHandler(.failure(ResponseError(.requestError)))
        }
    }
    
    func authorizeDocuments(identificationUID: String, completionHandler: @escaping (Result<Identification, ResponseError>) -> Void) {

        do {
            let request = try DocumentsAuthorizeRequest(identificationUID: identificationUID)
            apiClient.execute(request: request, answerType: Identification.self) { result in
                completionHandler(result)
            }
        } catch {
            completionHandler(.failure(ResponseError(.requestError)))
        }
    }

    func getMobileNumber(completionHandler: @escaping (Result<MobileNumber, ResponseError>) -> Void) {
        
        let request = MobileNumberRequest()
        apiClient.execute(request: request, answerType: MobileNumber.self) { result in
            completionHandler(result)
        }
    }
    
    private func getDocument(withId id: String, completionHandler: @escaping (Result<URL?, ResponseError>) -> Void) {
        do {
            let request = try DocumentDownloadRequest(documentUID: id)
            apiClient.download(request: request) { result in
                completionHandler(result)
            }
        } catch {
            completionHandler(.failure(ResponseError(.requestError)))
        }
    }
}
