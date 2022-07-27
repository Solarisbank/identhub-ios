//
//  StatusCheckServiceMock.swift
//  IdentHubSDKQESTests
//

import IdentHubSDKCore
@testable import IdentHubSDKQES
import IdentHubSDKTestBase

final internal class StatusCheckServiceMock: StatusCheckService {
    var recorder: TestRecorder?
    
    var setupNewCodeTimerCallsCount = 0
    var setupNewCodeTimerArguments: [(Int) -> Void] = []
    var setupNewCodeTimerResult: Int?
    var setupNewCodeTimerCompletion: (() -> Void)?

    var setupStatusVerificationTimerCallsCount = 0
    var setupStatusVerificationTimerArguments: [(identificationUID: String, callback: (Result<String, APIError>) -> Void)] = []
    var setupStatusVerificationTimerCompletion: (() -> Void)?
    var setupStatusVerificationResult: Result<String, APIError>?
    
    var invalidateNewCodeTimerCallsCount = 0
    var invalidateNewCodeTimerCompletion: (() -> Void)?
    
    init(recorder: TestRecorder? = nil) {
        self.recorder = recorder
    }
    
    func setupNewCodeTimer(callback: @escaping (Int) -> Void) {
        recorder?.record(event: .service, value: "StatusCheckService." + #function)
        
        setupNewCodeTimerCallsCount += 1
        
        setupNewCodeTimerArguments.append(callback)
        
        if let result = setupNewCodeTimerResult {
            callback(result)
            
            setupNewCodeTimerResult = nil
        }
        
        setupNewCodeTimerCompletion?()
    }
    
    func setupStatusVerificationTimer(identificationUID: String, callback: @escaping (Result<String, APIError>) -> Void) {
        recorder?.record(event: .service, value: "StatusCheckService." + #function)
        
        setupStatusVerificationTimerCallsCount += 1
        
        setupStatusVerificationTimerArguments.append((identificationUID, callback))
        
        if let result = setupStatusVerificationResult {
            callback(result)
            
            setupStatusVerificationResult = nil
        }
        
        setupStatusVerificationTimerCompletion?()
    }
    
    func invalidateNewCodeTimer() {
        recorder?.record(event: .service, value: "StatusCheckService." + #function)
        
        invalidateNewCodeTimerCallsCount += 1
        
        invalidateNewCodeTimerCompletion?()
    }
}
