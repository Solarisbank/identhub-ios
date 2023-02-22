//
//  VerificationService.swift
//  IdentHubSDK
//

import Foundation
import UIKit
import IdentHubSDKCore

protocol VerificationService: AnyObject {
    
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

}

private extension VerificationService {
    func log(error: Error, for function: StaticString = #function) {
        SBLog.warn("Got error for \(function): \(error.localizedDescription)")
    }
}
