//
//  VerificationService.swift
//  IdentHubSDK
//

import Foundation

/// Service providing resources for verification.
final class VerificationService {

    // MARK: Private properties

    private let apiClient: APIClient
    private let sessionInfoProvider: SessionInfoProvider

    // MARK: Initializers

    init(apiClient: APIClient, sessionInfoProvider: SessionInfoProvider) {
        self.apiClient = apiClient
        self.sessionInfoProvider = sessionInfoProvider
    }

    // MARK: Public methods

    /// Method defined what the identification method should execute
    /// - Parameter completionHandler: Response with enabled identification methods
    func defineIdentificationMethod(completionHandler: @escaping (Result<IdentificationMethod, APIError>) -> Void) {

        do {
            let request = try IdentificationMethodRequest(sessionToken: sessionInfoProvider.sessionToken)

            apiClient.execute(request: request, answerType: IdentificationMethod.self) { result in
                completionHandler(result)
            }
        } catch RequestError.emptySessionID {
            completionHandler(.failure(APIError.requestError))
            print("Fail with init mobile number authorization request. Session token is empty")
        } catch {
            completionHandler(.failure(APIError.requestError))
            print("Unexpected init mobile number auth request: \(error)")
        }
    }

    /// Method obtains identification process info details
    /// - Parameter completionHandler: Response with identification details
    func obtainIdentificationInfo(completionHandler: @escaping (Result<IdentificationInfo, APIError>) -> Void) {

        do {
            let request = try IdentificationInfoRequest(sessionToken: sessionInfoProvider.sessionToken)

            apiClient.execute(request: request, answerType: IdentificationInfo.self) { result in
                completionHandler(result)
            }
        } catch RequestError.emptySessionID {
            completionHandler(.failure(APIError.requestError))
            print("Fail with init mobile number authorization request. Session token is empty")
        } catch {
            completionHandler(.failure(APIError.requestError))
            print("Unexpected init mobile number auth request: \(error)")
        }
    }

    /// Authorize mobile number and send sms with a TAN.
    ///
    /// - Parameter completionHandler: Response back if the verification was successful.
    func authorizeMobileNumber(completionHandler: @escaping (Result<MobileNumber, APIError>) -> Void) {

        do {
            let request = try MobileNumberAuthorizeRequest(sessionId: sessionInfoProvider.sessionToken)

            apiClient.execute(request: request, answerType: MobileNumber.self) { result in
                completionHandler(result)
            }
        } catch RequestError.emptySessionID {
            completionHandler(.failure(APIError.requestError))
            print("Fail with init mobile number authorization request. Session token is empty")
        } catch {
            completionHandler(.failure(APIError.requestError))
            print("Unexpected init mobile number auth request: \(error)")
        }
    }

    /// Confirm if TAN complies with the mobile number.
    ///
    /// - Parameters:
    ///     - token: Code sent for the given phone number.
    ///     - completionHandler: Response back if the verification was successful.
    func verifyMobileNumberTAN(token: String, completionHandler: @escaping (Result<MobileNumber, APIError>) -> Void) {

        do {
            let request = try MobileNumberTANRequest(sessionId: sessionInfoProvider.sessionToken, token: token)
            apiClient.execute(request: request, answerType: MobileNumber.self) { result in
                completionHandler(result)
            }
        } catch RequestError.emptySessionID {
            completionHandler(.failure(APIError.requestError))
            print("Error with init mobile number TAN request initialization, session id is empty")
        } catch RequestError.emptyToken {
            completionHandler(.failure(APIError.requestError))
            print("Error with init mobile number TAN request initialization, number TOKEN is empty")
        } catch {
            completionHandler(.failure(APIError.requestError))
            print("Unexpected init mobile number auth request: \(error)")
        }
    }

    /// Verify if IBAN is correct.
    ///
    /// - Parameters:
    ///     - iban: IBAN provided by the user.
    ///     - completionHandler: Response back if the verification was successful.
    func verifyIBAN(_ iban: String, completionHandler: @escaping (Result<Identification, APIError>) -> Void) {

        do {
            var request: Request

            switch sessionInfoProvider.identificationStep {
            case .bankIDIBAN:
                request = try BankIDIBANRequest(sessionToken: sessionInfoProvider.sessionToken, iban: iban)
            default:
                request = try IBANRequest(sessionToken: sessionInfoProvider.sessionToken, iban: iban)
            }

            apiClient.execute(request: request, answerType: Identification.self) { result in
                completionHandler(result)
            }
        } catch RequestError.emptySessionToken {
            completionHandler(.failure(APIError.requestError))
            print("Error IBAN request init session with empty session token value")
        } catch RequestError.emptyIBAN {
            completionHandler(.failure(APIError.requestError))
            print("Error IBAN request init session with empty iban value")
        } catch {
            completionHandler(.failure(APIError.requestError))
            print("Unexpected init mobile number auth request: \(error)")
        }
    }

    /// Authorize signing the documents and send sms with a TAN.
    ///
    /// - Parameter completionHandler: Response back if the verification was successful.
    func authorizeDocuments(completionHandler: @escaping (Result<Identification, APIError>) -> Void) {
        guard let identificationUID = sessionInfoProvider.identificationUID else { return }

        do {
            let request = try DocumentsAuthorizeRequest(sessionToken: sessionInfoProvider.sessionToken, identificationUID: identificationUID)
            apiClient.execute(request: request, answerType: Identification.self) { result in
                completionHandler(result)
            }
        } catch RequestError.emptySessionToken {
            completionHandler(.failure(APIError.requestError))
            print("Error with init value of the documents authentication request, session token is empty")
        } catch RequestError.emptyIUID {
            completionHandler(.failure(APIError.requestError))
            print("Error with init value of the documents authentication request, the id of the current identification is empty")
        } catch {
            completionHandler(.failure(APIError.requestError))
            print("Unexpected init mobile number auth request: \(error)")
        }
    }

    /// Confirm the TAN while signing the documents.
    ///
    /// - Parameters:
    ///     - token: Code sent for the given phone number.
    ///     - completionHandler: Response back if the verification was successful.
    func verifyDocumentsTAN(token: String, completionHandler: @escaping (Result<Identification, APIError>) -> Void) {
        guard let identificationUID = sessionInfoProvider.identificationUID else { return }

        do {
            let request = try DocumentsTANRequest(sessionToken: sessionInfoProvider.sessionToken, identificationUID: identificationUID, token: token)
            apiClient.execute(request: request, answerType: Identification.self) { result in
                completionHandler(result)
            }
        } catch RequestError.emptySessionToken {
            completionHandler(.failure(APIError.requestError))
            print("Init documents TAN verifiaction request fails, session token is empty")
        } catch RequestError.emptyIUID {
            completionHandler(.failure(APIError.requestError))
            print("Init documents TAN verifiaction request fails, the id of the current identification is empty")
        } catch RequestError.emptyToken {
            completionHandler(.failure(APIError.requestError))
            print("Init documents TAN verifiaction request fails, token obtained to sign documents is empty")
        } catch {
            completionHandler(.failure(APIError.requestError))
            print("Unexpected init mobile number auth request: \(error)")
        }
    }

    /// Get indentification.
    ///
    /// - Parameter completionHandler: Response back if the verification was successful.
    func getIdentification(completionHandler: @escaping (Result<Identification, APIError>) -> Void) {
        guard let identificationUID = sessionInfoProvider.identificationUID else { return }

        do {
            let request = try IdentificationRequest(sessionToken: sessionInfoProvider.sessionToken, identificationUID: identificationUID)
            apiClient.execute(request: request, answerType: Identification.self) { result in
                completionHandler(result)
            }
        } catch RequestError.emptySessionToken {
            completionHandler(.failure(APIError.requestError))
            print("Init of the identification request fails, session token is empty")
        } catch RequestError.emptyIUID {
            completionHandler(.failure(APIError.requestError))
            print("Init of the identification request fails, the id of the current identification is empty")
        } catch {
            completionHandler(.failure(APIError.requestError))
            print("Unexpected init mobile number auth request: \(error)")
        }
    }

    /// Get Fourthline indentification data.
    ///
    /// - Parameter completionHandler: Response back if the fourthline detail.
    func getFourthlineIdentification(completionHandler: @escaping (Result<FourthlineIdentification, APIError>) -> Void) {
        do {
            let request = try FourthlineIdentificationRequest(sessionToken: sessionInfoProvider.sessionToken)

            apiClient.execute(request: request, answerType: FourthlineIdentification.self) { result in
                completionHandler(result)
            }
        } catch RequestError.emptySessionToken {
            completionHandler(.failure(APIError.requestError))
            print("Init of the Fourthline identification request fails, session token is empty")
        } catch RequestError.emptyIUID {
            completionHandler(.failure(APIError.requestError))
            print("Init of the Fourthline identification request fails, the id of the current identification is empty")
        } catch {
            completionHandler(.failure(APIError.requestError))
            print("Unexpected init Fourthline identification request: \(error)")
        }
    }

    /// Get document.
    ///
    /// - Parameters:
    ///     - documentId: Id of the document resource.
    ///     - completionHandler: Response back with the document or error.
    func getDocument(documentId: String, completionHandler: @escaping (Result<URL?, APIError>) -> Void) {

        do {
            let request = try DocumentDownloadRequest(sessionToken: sessionInfoProvider.sessionToken, documentUID: documentId)
            apiClient.download(request: request) { result in
                completionHandler(result)
            }
        } catch RequestError.emptySessionToken {
            completionHandler(.failure(APIError.requestError))
            print("Init document download request fails, the token of the current session is empty")
        } catch RequestError.emptyDUID {
            completionHandler(.failure(APIError.requestError))
            print("Init document download request fails, the id of the current document is empty")
        } catch {
            completionHandler(.failure(APIError.requestError))
            print("Unexpected init mobile number auth request: \(error)")
        }
    }

    /// Method uploaded zip file with person kyc data
    /// - Parameters:
    ///   - fileURL: url of the file location
    ///   - completionHandler: Response back with uploaded document status
    func uploadKYCZip(fileURL: URL, completionHandler: @escaping (Result<UploadFourthlineZip, APIError>) -> Void) {

        do {
            let request = try UploadKYCRequest(sessionToken: sessionInfoProvider.sessionToken, sessionID: sessionInfoProvider.identificationUID ?? "", fileURL: fileURL)

            apiClient.execute(request: request, answerType: UploadFourthlineZip.self) { result in
                completionHandler(result)
            }
        } catch RequestError.emptySessionToken {
            completionHandler(.failure(APIError.requestError))
            print("Upload zip file request fails, the token of the current session is empty")
        } catch RequestError.emptySessionID {
            completionHandler(.failure(APIError.requestError))
            print("Upload zip file request fails, the ID of the current session is empty")
        } catch {
            completionHandler(.failure(APIError.requestError))
            print("Unexpected upload fourthline zip request: \(error)")
        }
    }

    /// Method fetched identified person data from the server
    /// - Parameter completion: Response back with required person data
    func fetchPersonData(completion: @escaping (Result<PersonData, APIError>) -> Void) {
        do {
            let request = try PersonDataRequest(sessionToken: sessionInfoProvider.sessionToken, uid: sessionInfoProvider.identificationUID ?? "")

            apiClient.execute(request: request, answerType: PersonData.self) { result in
                completion(result)
            }
        } catch RequestError.emptySessionToken {
            completion(.failure(APIError.requestError))
            print("Fetch person data request fails, the token of the current session is empty")
        } catch RequestError.emptySessionID {
            completion(.failure(APIError.requestError))
            print("Fetch person data request fails, the ID of the person is empty")
        } catch {
            completion(.failure(APIError.requestError))
            print("Unexpected fetch person data request: \(error)")
        }
    }

    /// Method fetched IP address used by device published request
    /// - Parameter completion: Resopnse back with device ip-address data
    func fetchIPAddress(completion: @escaping (Result<IPAddress, APIError>) -> Void) {

        do {
            let request = try IPAddressRequest(sessionToken: sessionInfoProvider.sessionToken)
            apiClient.execute(request: request, answerType: IPAddress.self) { result in
                completion(result)
            }
        } catch RequestError.emptySessionToken {
            completion(.failure(APIError.requestError))
            print("Fetch person data request fails, the token of the current session is empty")
        } catch {
            completion(.failure(APIError.requestError))
            print("Unexpected fetch person data request: \(error)")
        }
    }

    /// Method obtained status of the current Fourthline identification session status
    /// - Parameter completion: Response back with fourthline session status
    func obtainFourthlineIdentificationStatus(completion: @escaping (Result<FourthlineIdentificationStatus, APIError>) -> Void) {

        do {
            let request = try FourthlineIdentificationStatusRequest(sessionToken: sessionInfoProvider.sessionToken, uid: sessionInfoProvider.identificationUID ?? "")

            apiClient.execute(request: request, answerType: FourthlineIdentificationStatus.self) { result in
                completion(result)
            }
        } catch RequestError.emptySessionToken {
            completion(.failure(APIError.requestError))
            print("Fetch person data request fails, the token of the current session is empty")
        } catch RequestError.emptySessionID {
            completion(.failure(APIError.requestError))
            print("Fetch person data request fails, the ID of the person is empty")
        } catch {
            completion(.failure(APIError.requestError))
            print("Unexpected fetch person data request: \(error)")
        }
    }
}
