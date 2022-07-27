//
//  VerificationServiceMock.swift
//  IdentHubSDKQESTests
//

@testable import IdentHubSDKQES
import XCTest
import IdentHubSDKCore
import IdentHubSDKTestBase

final internal class VerificationServiceMock: VerificationService {
    var recorder: TestRecorder?
    
    var getIdentificationCallsCount = 0
    var getIdentificationArguments: [(identificationUID: String, completionHandler: (Result<Identification, ResponseError>) -> Void)] = []
    var getIdentificationResult: Result<Identification, ResponseError>?
    
    var downloadAndSaveDocumentCallsCount = 0
    var downloadAndSaveDocumentArguments: [(id: String, completion: (Result<URL, FileStorageError>) -> Void)] = []
    var downloadAndSaveDocumentResult: Result<URL, FileStorageError>?
    
    var getMobileNumberCallsCount = 0
    var getMobileNumberArguments: [(Result<MobileNumber, ResponseError>) -> Void] = []
    var getMobileNumberResult: Result<MobileNumber, ResponseError>?
    
    var authorizeDocumentsCallsCount = 0
    var authorizeDocumentsArguments: [(identificationUID: String, completionHandler: (Result<Identification, ResponseError>) -> Void)] = []
    var authorizeDocumentsResult: Result<Identification, ResponseError>?
    
    var verifyDocumentsTANCallsCount = 0
    var verifyDocumentsTANArguments: [(identificationUID: String, token: String, completionHandler: (Result<Identification, ResponseError>) -> Void)] = []
    var verifyDocumentsTANResult: Result<Identification, ResponseError>?
    
    init(recorder: TestRecorder? = nil) {
        self.recorder = recorder
    }
    
    func getIdentification(for identificationUID: String, completionHandler: @escaping (Result<Identification, ResponseError>) -> Void) {
        recorder?.record(event: .service, caller: self, arguments: identificationUID)
        
        getIdentificationCallsCount += 1
        
        getIdentificationArguments.append((identificationUID, completionHandler))
        
        if let result = getIdentificationResult {
            getIdentificationResult = nil
            
            completionHandler(result)
        }
    }
    
    func downloadAndSaveDocument(withId id: String, completion: @escaping (Result<URL, FileStorageError>) -> Void) {
        recorder?.record(event: .service, caller: self, arguments: id)
        
        downloadAndSaveDocumentCallsCount += 1
        
        downloadAndSaveDocumentArguments.append((id, completion))
        
        if let result = downloadAndSaveDocumentResult {
            downloadAndSaveDocumentResult = nil
            
            completion(result)
        }
    }
    
    func authorizeDocuments(identificationUID: String, completionHandler: @escaping (Result<Identification, ResponseError>) -> Void) {
        recorder?.record(event: .service, caller: self, arguments: identificationUID)
        
        authorizeDocumentsCallsCount += 1
        
        authorizeDocumentsArguments.append((identificationUID, completionHandler))
        
        if let result = authorizeDocumentsResult {
            authorizeDocumentsResult = nil
            
            completionHandler(result)
        }
    }
    
    func verifyDocumentsTAN(identificationUID: String, token: String, completionHandler: @escaping (Result<Identification, ResponseError>) -> Void) {
        recorder?.record(event: .service, caller: self, arguments: identificationUID, token)
        
        verifyDocumentsTANCallsCount += 1
        
        verifyDocumentsTANArguments.append((identificationUID, token, completionHandler))
        
        if let result = verifyDocumentsTANResult {
            verifyDocumentsTANResult = nil
            
            completionHandler(result)
        }
    }
    
    func getMobileNumber(completionHandler: @escaping (Result<MobileNumber, ResponseError>) -> Void) {
        recorder?.record(event: .service, caller: self)
        
        getMobileNumberCallsCount += 1
        
        getMobileNumberArguments.append(completionHandler)
        
        if let result = getMobileNumberResult {
            getMobileNumberResult = nil
            
            completionHandler(result)            
        }
    }
}
