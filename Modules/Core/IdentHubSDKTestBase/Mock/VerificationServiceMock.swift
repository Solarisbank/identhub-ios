//
//  VerificationServiceMock.swift
//  IdentHubSDKCoreTests
//

import XCTest
@testable import IdentHubSDKCore
import IdentHubSDKTestBase

final internal class VerificationServiceMock: VerificationService {
    var recorder: TestRecorder?
    
    var authorizeMobileNumberCallsCount = 0
    var authorizeMobileNumberArguments: [(Result<MobileNumber, ResponseError>) -> Void] = []
    var authorizeMobileNumberResult: Result<MobileNumber, ResponseError>?
    
    var verifyMobileNumberTANCallsCount = 0
    var verifyMobileNumberTANArguments: [(token: String, completionHandler: (Result<MobileNumber, ResponseError>) -> Void)] = []
    var verifyMobileNumberTANResult: Result<MobileNumber, ResponseError>?
    
    init(recorder: TestRecorder? = nil) {
        self.recorder = recorder
    }
    
    func authorizeMobileNumber(completionHandler: @escaping (Result<MobileNumber, ResponseError>) -> Void) {
        recorder?.record(event: .service, caller: self)
        
        authorizeMobileNumberCallsCount += 1
        authorizeMobileNumberArguments.append(completionHandler)
        
        if let result = authorizeMobileNumberResult {
            authorizeMobileNumberResult = nil
            completionHandler(result)
        }
    }
    
    func verifyMobileNumberTAN(token: String, completionHandler: @escaping (Result<MobileNumber, ResponseError>) -> Void) {
        recorder?.record(event: .service, caller: self, arguments: token, token)
        
        verifyMobileNumberTANCallsCount += 1
        verifyMobileNumberTANArguments.append((token, completionHandler))
        
        if let result = verifyMobileNumberTANResult {
            verifyMobileNumberTANResult = nil
            completionHandler(result)
        }
    }
    
}
