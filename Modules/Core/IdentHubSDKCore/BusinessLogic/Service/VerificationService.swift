//
//  VerificationService.swift
//  IdentHubSDKCore
//

import Foundation

internal protocol VerificationService: AnyObject {
    
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
