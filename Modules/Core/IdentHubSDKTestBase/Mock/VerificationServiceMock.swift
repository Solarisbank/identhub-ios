//
//  VerificationServiceMock.swift
//  IdentHubSDKCoreTests
//

import XCTest
@testable import IdentHubSDKCore
import IdentHubSDKTestBase

final internal class VerificationServiceMock: VerificationService {
    
    var recorder: TestRecorder?

    var identificationCallsCount = 0
    var identificationNumberArguments: [(Result<IdentificationMethod, ResponseError>) -> Void] = []
    var identificationResult: Result<IdentificationMethod, ResponseError>?
    
    var obtainInfoCallsCount = 0
    var obtainInfoNumberArguments: [(Result<IdentificationInfo, ResponseError>) -> Void] = []
    var obtainInfoResult: Result<IdentificationInfo, ResponseError>?
    
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
    
    func defineIdentificationMethod(completionHandler: @escaping (Result<IdentificationMethod, ResponseError>) -> Void) {
        recorder?.record(event: .service, caller: self)
        
        identificationCallsCount += 1
        identificationNumberArguments.append(completionHandler)
        
        if let result = identificationResult {
            identificationResult = nil
            completionHandler(result)
        }
    }
    
    func obtainIdentificationInfo(completionHandler: @escaping (Result<IdentificationInfo, ResponseError>) -> Void) {
        recorder?.record(event: .service, caller: self)
        
        obtainInfoCallsCount += 1
        obtainInfoNumberArguments.append(completionHandler)
        
        if let result = obtainInfoResult {
            obtainInfoResult = nil
            completionHandler(result)
        }
    }
    
}
