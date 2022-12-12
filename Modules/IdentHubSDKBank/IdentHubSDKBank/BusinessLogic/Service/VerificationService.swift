//
//  VerificationService.swift
//  Bank
//

import Foundation
import IdentHubSDKCore

internal protocol VerificationService {
    
    /// Verify if IBAN is correct.
    ///
    /// - Parameters:
    ///     - iban: IBAN provided by the user.
    ///     - completionHandler: Response back if the verification was successful.
    func verifyIBAN(_ iban: String, _ step: IdentificationStep, completionHandler: @escaping (Result<Identification, ResponseError>) -> Void)
    
    /// Get indentification.
    ///
    /// - Parameter completionHandler: Response back if the verification was successful.
    func getIdentification(
        for identificationUID: String,
        completionHandler: @escaping (Result<Identification, ResponseError>) -> Void
    )
    
}

internal struct VerificationServiceImpl: VerificationService {
    let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func verifyIBAN(_ iban: String, _ step: IdentificationStep, completionHandler: @escaping (Result<Identification, ResponseError>) -> Void) {
        do {
            var request: Request
            switch step {
            case .bankIDIBAN:
                request = try BankIDIBANRequest(iban: iban)
            default:
                request = try IBANRequest(iban: iban)
            }
            
            apiClient.execute(request: request, answerType: Identification.self) { result in
                completionHandler(result)
            }
        } catch {
            bankLog.error(error.logDescription)
            completionHandler(.failure(ResponseError(.requestError)))
        }
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
    
}
