//
//  VerificationServiceSpy.swift
//  IdentHubSDKQESTests
//

@testable import IdentHubSDKQES
import IdentHubSDKTestBase
import IdentHubSDKCore

final class VerificationServiceSpy: VerificationService {
    let verificationService: VerificationService
    let recorder: TestRecorder
    
    init(
        verificationService: VerificationService,
        recorder: TestRecorder
    ) {
        self.verificationService = verificationService
        self.recorder = recorder
    }
    
    func getIdentification(for identificationUID: String, completionHandler: @escaping (Result<Identification, ResponseError>) -> Void) {
        recorder.record(event: .service, caller: self, arguments: identificationUID)
        
        verificationService.getIdentification(for: identificationUID, completionHandler: completionHandler)
    }
    
    func downloadAndSaveDocument(withId id: String, completion: @escaping (Result<URL, FileStorageError>) -> Void) {
        recorder.record(event: .service, caller: self, arguments: id)
        
        verificationService.downloadAndSaveDocument(withId: id, completion: completion)
    }
    
    func verifyDocumentsTAN(identificationUID: String, token: String, completionHandler: @escaping (Result<Identification, ResponseError>) -> Void) {
        recorder.record(event: .service, caller: self, arguments: identificationUID, token)
        
        verificationService.verifyDocumentsTAN(identificationUID: identificationUID, token: token, completionHandler: completionHandler)
    }
    
    func authorizeDocuments(identificationUID: String, completionHandler: @escaping (Result<Identification, ResponseError>) -> Void) {
        recorder.record(event: .service, caller: self, arguments: identificationUID)
        
        verificationService.authorizeDocuments(identificationUID: identificationUID, completionHandler: completionHandler)
    }
    
    func getMobileNumber(completionHandler: @escaping (Result<MobileNumber, ResponseError>) -> Void) {
        recorder.record(event: .service, caller: self)
        
        verificationService.getMobileNumber(completionHandler: completionHandler)
    }
}
