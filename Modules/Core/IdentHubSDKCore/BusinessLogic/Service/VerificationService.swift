//
//  VerificationService.swift
//  IdentHubSDKCore
//

import Foundation

internal protocol VerificationService: AnyObject {
    
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
    
}

/// Service providing resources for verification.
final class VerificationServiceImpl: VerificationService {
    
    // MARK: Private properties
    
    private let apiClient: APIClient
    
    // MARK: Initializers

    init(apiClient: APIClient) {
        self.apiClient = apiClient
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
            completionHandler(.failure(ResponseError(.requestError)))
        }
    }
    
}
