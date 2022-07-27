//
//  StatusCheckServiceSpy.swift
//  IdentHubSDKQESTests
//

@testable import IdentHubSDKQES
import IdentHubSDKTestBase
import IdentHubSDKCore

final class StatusCheckServiceSpy: StatusCheckService {
    var statusCheckService: StatusCheckService
    var recorder: TestRecorder
    
    init(
        statusCheckService: StatusCheckService,
        recorder: TestRecorder
    ) {
        self.statusCheckService = statusCheckService
        self.recorder = recorder
    }
    
    func setupNewCodeTimer(callback: @escaping (Int) -> Void) {
        recorder.record(event: .service, caller: self)
        
        statusCheckService.setupNewCodeTimer(callback: callback)
    }
    
    func setupStatusVerificationTimer(identificationUID: String, callback: @escaping (Result<String, APIError>) -> Void) {
        recorder.record(event: .service, caller: self, arguments: identificationUID)
        
        statusCheckService.setupStatusVerificationTimer(identificationUID: identificationUID, callback: callback)
    }
    
    func invalidateNewCodeTimer() {
        recorder.record(event: .service, caller: self)
        
        statusCheckService.invalidateNewCodeTimer()
    }
}
