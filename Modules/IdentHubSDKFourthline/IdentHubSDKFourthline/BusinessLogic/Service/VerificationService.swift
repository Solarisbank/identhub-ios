//
//  VerificationService.swift
//  Fourthline

import UIKit
import Foundation
import IdentHubSDKCore

internal protocol VerificationService {
    
    /// Get Namirial Terms and conditions url.
    ///
    /// - Parameter completionHandler: Response back with required terms and conditions data..
    func getNamirialTermsConditions(completionHandler: @escaping (Result<TermsAndConditions, ResponseError>) -> Void)
    
    /// Post Acceptance of Namirial Terms and conditions.
    ///
    /// - Parameter completionHandler: Response back with required terms and conditions data..
    func acceptNamirialTermsConditions(documentid:String, completionHandler: @escaping (Result<AcceptedTermsConditionsData, ResponseError>) -> Void)
    
    /// Get Fourthline indentification data.
    ///
    /// - Parameter completionHandler: Response back if the fourthline detail.
    func getFourthlineIdentification(completionHandler: @escaping (Result<FourthlineIdentification, ResponseError>) -> Void)
    
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

internal class VerificationServiceImpl: VerificationService {
    
    // MARK: Private properties
    
    let apiClient: APIClient
    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    private var storage: Storage
    
    // MARK: Initializers
    
    init(apiClient: APIClient, storage: Storage) {
        self.apiClient = apiClient
        self.storage = storage
    }
    
    // MARK: Protocol methods
    
    func getFourthlineIdentification(completionHandler: @escaping (Result<FourthlineIdentification, ResponseError>) -> Void) {
        do {
            let request = try FourthlineIdentificationRequest(method: storage[.identificationStep] ?? .fourthline)

            apiClient.execute(request: request, answerType: FourthlineIdentification.self) { result in
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
            let request = try UploadKYCRequest(sessionID: storage[.identificationUID] ?? "", fileURL: fileURL)

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
        fourthlineLog.info("Starting KYCZip upload \(Date())")
        backgroundTaskId = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endKYCZipUploadBackgroundTask()
        }
    }
    
    func endKYCZipUploadBackgroundTask() {
        guard backgroundTaskId != .invalid else {
            return
        }
        
        fourthlineLog.info("Finished KYCZip upload \(Date())")
        UIApplication.shared.endBackgroundTask(backgroundTaskId)
        backgroundTaskId = .invalid
    }

    func fetchPersonData(completion: @escaping (Result<PersonData, ResponseError>) -> Void) {
        do {
            let request = try PersonDataRequest(uid: storage[.identificationUID] ?? "")

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
    
    func getNamirialTermsConditions(completionHandler: @escaping (Result<TermsAndConditions, ResponseError>) -> Void) {
        let request = GetTermsConditionsRequest()
        
        apiClient.execute(request: request, answerType: TermsAndConditions.self) { result in
            completionHandler(result)
        }
    }
    
    func acceptNamirialTermsConditions(documentid:String, completionHandler: @escaping (Result<AcceptedTermsConditionsData, ResponseError>) -> Void) {
        let request = AcceptTermsConditionsRequest(documentid: documentid)
        apiClient.execute(request: request, answerType: AcceptedTermsConditionsData.self) { result in
            completionHandler(result)
        }
    }
    
    func obtainFourthlineIdentificationStatus(completion: @escaping (Result<FourthlineIdentificationStatus, ResponseError>) -> Void) {
        do {
            let request = try FourthlineIdentificationStatusRequest(uid: storage[.identificationUID] ?? "")

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
        fourthlineLog.warn("Got error for \(function): \(error.localizedDescription)")
    }
}
