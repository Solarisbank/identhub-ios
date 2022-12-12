//
//  VerificationServiceMock.swift
//  IdentHubSDKBankTests
//

@testable import IdentHubSDKBank
import XCTest
import IdentHubSDKCore
import IdentHubSDKTestBase

final internal class VerificationServiceMock: VerificationService {
    var recorder: TestRecorder?
    
    var getIdentificationCallsCount = 0
    var getIdentificationArguments: [(identificationUID: String, completionHandler: (Result<Identification, ResponseError>) -> Void)] = []
    var getIdentificationResult: Result<Identification, ResponseError>?
    
    var verifyIBANCallsCount = 0
    var verifyIBANArguments: [(iban: String, completionHandler: (Result<Identification, ResponseError>) -> Void)] = []
    var verifyIBANResult: Result<Identification, ResponseError>?
    
    init(recorder: TestRecorder? = nil) {
        self.recorder = recorder
    }
    
    func verifyIBAN(_ iban: String, _ step: IdentHubSDKCore.IdentificationStep, completionHandler: @escaping (Result<IdentHubSDKCore.Identification, IdentHubSDKCore.ResponseError>) -> Void) {
        
        verifyIBANCallsCount += 1
        verifyIBANArguments.append((iban, completionHandler))
        
        if let result = verifyIBANResult {
            verifyIBANResult = nil
            completionHandler(result)
        }
    }
    
    func getIdentification(for identificationUID: String, completionHandler: @escaping (Result<IdentHubSDKCore.Identification, IdentHubSDKCore.ResponseError>) -> Void) {
        recorder?.record(event: .service, caller: self, arguments: identificationUID)
        
        getIdentificationCallsCount += 1
        getIdentificationArguments.append((identificationUID, completionHandler))
        
        if let result = getIdentificationResult {
            getIdentificationResult = nil
            completionHandler(result)
        }
    }

}
