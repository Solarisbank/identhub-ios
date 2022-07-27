//
//  VerificationService.swift
//  IdentHubSDK
//

import Foundation
import UIKit
import IdentHubSDKCore

protocol VerificationService: AnyObject {
    
    /// Method defined what the identification method should execute
    /// - Parameter completionHandler: Response with enabled identification methods
    func defineIdentificationMethod(completionHandler: @escaping (Result<IdentificationMethod, ResponseError>) -> Void)
    
    /// Method obtains identification process info details
    /// - Parameter completionHandler: Response with identification details
    func obtainIdentificationInfo(completionHandler: @escaping (Result<IdentificationInfo, ResponseError>) -> Void)
    
    /// Authorize mobile number and send sms with a TAN.
    /// - Parameter completionHandler: Response back if the verification was successful.
    func authorizeMobileNumber(completionHandler: @escaping (Result<MobileNumber, ResponseError>) -> Void)
    
    /// Confirm if TAN complies with the mobile number.
    ///
    /// - Parameters:
    ///     - token: Code sent for the given phone number.
    ///     - completionHandler: Response back if the verification was successful.
    func verifyMobileNumberTAN(token: String, completionHandler: @escaping (Result<MobileNumber, ResponseError>) -> Void)
    
    /// Verify if IBAN is correct.
    ///
    /// - Parameters:
    ///     - iban: IBAN provided by the user.
    ///     - completionHandler: Response back if the verification was successful.
    func verifyIBAN(_ iban: String, completionHandler: @escaping (Result<Identification, ResponseError>) -> Void)
    
    /// Get indentification.
    ///
    /// - Parameter completionHandler: Response back if the verification was successful.
    func getIdentification(completionHandler: @escaping (Result<Identification, ResponseError>) -> Void)
    
    /// Get Fourthline indentification data.
    ///
    /// - Parameter completionHandler: Response back if the fourthline detail.
    func getFourthlineIdentification(completionHandler: @escaping (Result<FourthlineIdentification, ResponseError>) -> Void)
    
    /// Get document.
    ///
    /// - Parameters:
    ///     - documentId: Id of the document resource.
    ///     - completionHandler: Response back with the document or error.
    func getDocument(documentId: String, completionHandler: @escaping (Result<URL?, ResponseError>) -> Void)
    
    /// Method uploaded zip file with person kyc data
    /// - Parameters:
    ///   - fileURL: url of the file location
    ///   - completionHandler: Response back with uploaded document status
    func uploadKYCZip(fileURL: URL, completionHandler: @escaping (Result<UploadFourthlineZip, ResponseError>) -> Void)
    
    /// Method fetched identified person data from the server
    /// - Parameter completion: Response back with required person data
    func fetchPersonData(completion: @escaping (Result<PersonData, ResponseError>) -> Void)
    
    /// Method fetched IP address used by device published request
    /// - Parameter completion: Resopnse back with device ip-address data
    func fetchIPAddress(completion: @escaping (Result<IPAddress, ResponseError>) -> Void)
    
    /// Method obtained status of the current Fourthline identification session status
    /// - Parameter completion: Response back with fourthline session status
    func obtainFourthlineIdentificationStatus(completion: @escaping (Result<FourthlineIdentificationStatus, ResponseError>) -> Void)
}

/// Service providing resources for verification.
final class VerificationServiceImplementation: VerificationService {

    // MARK: Private properties

    private let apiClient: APIClient
    private let sessionInfoProvider: SessionInfoProvider
    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid

    // MARK: Initializers

    init(apiClient: APIClient, sessionInfoProvider: SessionInfoProvider) {
        self.apiClient = apiClient
        self.sessionInfoProvider = sessionInfoProvider
    }

    // MARK: Protocol methods

    func defineIdentificationMethod(completionHandler: @escaping (Result<IdentificationMethod, ResponseError>) -> Void) {
        let request = IdentificationMethodRequest()
        
        apiClient.execute(request: request, answerType: IdentificationMethod.self) { result in
            completionHandler(result)
        }
    }

    func obtainIdentificationInfo(completionHandler: @escaping (Result<IdentificationInfo, ResponseError>) -> Void) {
        let request = IdentificationInfoRequest()
        
        apiClient.execute(request: request, answerType: IdentificationInfo.self) { result in
            completionHandler(result)
        }
    }

    func authorizeMobileNumber(completionHandler: @escaping (Result<MobileNumber, ResponseError>) -> Void) {
        let request = MobileNumberAuthorizeRequest()
        
        apiClient.execute(request: request, answerType: MobileNumber.self) { result in
            completionHandler(result)
        }
    }
    
    func verifyMobileNumberTAN(token: String, completionHandler: @escaping (Result<MobileNumber, ResponseError>) -> Void) {
        do {
            let request = try MobileNumberTANRequest(token: token)
            
            apiClient.execute(request: request, answerType: MobileNumber.self) { result in
                completionHandler(result)
            }
        } catch {
            log(error: error)
            completionHandler(.failure(ResponseError(.requestError)))
        }
    }

    func verifyIBAN(_ iban: String, completionHandler: @escaping (Result<Identification, ResponseError>) -> Void) {
        do {
            var request: Request

            switch sessionInfoProvider.identificationStep {
            case .bankIDIBAN:
                request = try BankIDIBANRequest(iban: iban)
            default:
                request = try IBANRequest(iban: iban)
            }

            apiClient.execute(request: request, answerType: Identification.self) { result in
                completionHandler(result)
            }
        } catch {
            log(error: error)
            completionHandler(.failure(ResponseError(.requestError)))
        }
    }

    func getIdentification(completionHandler: @escaping (Result<Identification, ResponseError>) -> Void) {
        guard let identificationUID = sessionInfoProvider.identificationUID else {
            completionHandler(.failure(.init(.requestError)))
            
            return
        }

        do {
            let request = try IdentificationRequest(identificationUID: identificationUID)
            
            apiClient.execute(request: request, answerType: Identification.self) { result in
                completionHandler(result)
            }
        } catch {
            log(error: error)
            completionHandler(.failure(ResponseError(.requestError)))
        }
    }

    func getFourthlineIdentification(completionHandler: @escaping (Result<FourthlineIdentification, ResponseError>) -> Void) {
        do {
            let request = try FourthlineIdentificationRequest(method: sessionInfoProvider.identificationStep ?? .fourthline)

            apiClient.execute(request: request, answerType: FourthlineIdentification.self) { result in
                completionHandler(result)
            }
        } catch {
            log(error: error)
            completionHandler(.failure(ResponseError(.requestError)))
        }
    }

    func getDocument(documentId: String, completionHandler: @escaping (Result<URL?, ResponseError>) -> Void) {
        do {
            let request = try DocumentDownloadRequest(documentUID: documentId)
            
            apiClient.download(request: request) { result in
                completionHandler(result)
            }
        } catch {
            log(error: error)
            completionHandler(.failure(ResponseError(.requestError)))
        }
    }

    func uploadKYCZip(fileURL: URL, completionHandler: @escaping (Result<UploadFourthlineZip, ResponseError>) -> Void) {
        startKYCZipUploadBackgroundTask()
        
        do {
            let request = try UploadKYCRequest(sessionID: sessionInfoProvider.identificationUID ?? "", fileURL: fileURL)

            apiClient.execute(request: request, answerType: UploadFourthlineZip.self) { [weak self] result in
                self?.endKYCZipUploadBackgroundTask()
                completionHandler(result)
            }
        } catch {
            log(error: error)
            completionHandler(.failure(ResponseError(.requestError)))
            endKYCZipUploadBackgroundTask()
        }
    }
    
    func startKYCZipUploadBackgroundTask() {
        SBLog.info("Starting KYCZip upload \(Date())")
        backgroundTaskId = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endKYCZipUploadBackgroundTask()
        }
    }
    
    func endKYCZipUploadBackgroundTask() {
        guard backgroundTaskId != .invalid else {
            return
        }
        
        SBLog.info("Finished KYCZip upload \(Date())")
        
        UIApplication.shared.endBackgroundTask(backgroundTaskId)
        backgroundTaskId = .invalid
    }

    func fetchPersonData(completion: @escaping (Result<PersonData, ResponseError>) -> Void) {
        do {
            let request = try PersonDataRequest(uid: sessionInfoProvider.identificationUID ?? "")

            apiClient.execute(request: request, answerType: PersonData.self) { result in
                completion(result)
            }
        } catch {
            log(error: error)
            completion(.failure(ResponseError(.requestError)))
        }
    }

    func fetchIPAddress(completion: @escaping (Result<IPAddress, ResponseError>) -> Void) {
        let request = IPAddressRequest()
        
        apiClient.execute(request: request, answerType: IPAddress.self) { result in
            completion(result)
        }
    }

    func obtainFourthlineIdentificationStatus(completion: @escaping (Result<FourthlineIdentificationStatus, ResponseError>) -> Void) {
        do {
            let request = try FourthlineIdentificationStatusRequest(uid: sessionInfoProvider.identificationUID ?? "")

            apiClient.execute(request: request, answerType: FourthlineIdentificationStatus.self) { result in
                completion(result)
            }
        } catch {
            log(error: error)
            completion(.failure(ResponseError(.requestError)))
        }
    }
}

private extension VerificationService {
    func log(error: Error, for function: StaticString = #function) {
        SBLog.warn("Got error for \(function): \(error.localizedDescription)")
    }
}
