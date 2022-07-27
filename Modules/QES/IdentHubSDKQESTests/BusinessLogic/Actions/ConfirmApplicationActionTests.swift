//
//  ConfirmApplicationActionTests.swift
//  IdentHubSDKQESTests
//

@testable import IdentHubSDKQES
@testable import IdentHubSDKCore
import XCTest
import IdentHubSDKTestBase

final class ConfirmApplicationActionTests: XCTestCase {
    private var verificationService: VerificationServiceMock!
    private var presenter: UpdateableShowableMock!
    
    private let identificationUID = "identification_uid"
    
    override func setUp() {
        super.setUp()
        
        verificationService = VerificationServiceMock()
        presenter = UpdateableShowableMock()
    }
    
    override func tearDown() {
        super.tearDown()
        
        verificationService = nil
        presenter = nil
    }
    
    func test_perform_updatesViewWithExpectedState() {
        let input = ConfirmApplicationActionInput(identificationUID: "identification_uid")
        let expectedState = ConfirmApplicationState(
            hasQuitButton: true,
            documents: [],
            hasTermsAndConditionsLink: true
        )
        
        let sut = makeSut()
        
        var result: Showable?
        
        assertAsync { expectation in
            expectation.isInverted = true
            
            result = sut.perform(input: input) { _ in
                expectation.fulfill()
            }
        }
        
        XCTAssertIdentical(presenter.toShowable(), result?.toShowable())
        XCTAssertNotNil(presenter.eventHandler)
        XCTAssertEqual(presenter.updateViewCallsCount, 1)
        XCTAssertEqual(presenter.updateViewArguments.last, expectedState)
    }
    
    // MARK: - loadDocuments
    
    func test_loadDocuments_completesWithFailure_callsGetIdentification_doesNotUpdateState() throws {
        let input = ConfirmApplicationActionInput(identificationUID: identificationUID)
        
        let sut = makeSut()
        
        _ = sut.perform(input: input) { _ in }
        
        presenter.eventHandler?.loadDocuments()
        
        XCTAssertEqual(verificationService.getIdentificationCallsCount, 1)
        XCTAssertEqual(verificationService.getIdentificationArguments.last?.identificationUID, identificationUID)
        
        let getIdentificationCompletion = try XCTUnwrap(verificationService.getIdentificationArguments.last?.completionHandler)
        
        assertAsync { expectation in
            expectation.isInverted = true

            presenter.updateViewCompletion = {
                expectation.fulfill()
            }
            
            getIdentificationCompletion(.failure(ResponseError(.unauthorizedAction)))
        }
    }
    
    func test_loadDocuments_completesWithSuccessWithNoDocuments_callsGetIndentification_doesNotUpdateState() throws {
        let input = ConfirmApplicationActionInput(identificationUID: identificationUID)
        
        let sut = makeSut()
        
        _ = sut.perform(input: input) { _ in }
        
        presenter.eventHandler?.loadDocuments()
        
        XCTAssertEqual(verificationService.getIdentificationCallsCount, 1)
        XCTAssertEqual(verificationService.getIdentificationArguments.last?.identificationUID, identificationUID)
        
        let getIdentificationCompletion = try XCTUnwrap(verificationService.getIdentificationArguments.last?.completionHandler)
        
        assertAsync { expectation in
            expectation.isInverted = true
            
            presenter.updateViewCompletion = {
                expectation.fulfill()
            }
            
            getIdentificationCompletion(.success(Identification.mock(documents: nil)))
        }
    }
    
    func test_loadDocuments_completesWithSuccessWithEmptyDocuments_callsGetIndentification_updatesState() throws {
        let input = ConfirmApplicationActionInput(identificationUID: identificationUID)
        let expectedState = ConfirmApplicationState(
            hasQuitButton: true,
            documents: [],
            hasTermsAndConditionsLink: true
        )
        
        let sut = makeSut()
        
        _ = sut.perform(input: input) { _ in }
        
        presenter.eventHandler?.loadDocuments()
        
        XCTAssertEqual(verificationService.getIdentificationCallsCount, 1)
        XCTAssertEqual(verificationService.getIdentificationArguments.last?.identificationUID, identificationUID)
        
        let getIdentificationCompletion = try XCTUnwrap(verificationService.getIdentificationArguments.last?.completionHandler)
        
        assertAsync { expectation in
            presenter.updateViewCompletion = {
                XCTAssertEqual(self.presenter.updateViewArguments.last, expectedState)
                
                expectation.fulfill()
            }

            getIdentificationCompletion(.success(Identification.mock(documents: [])))
        }
    }
    
    func test_loadDocuments_completesWithSuccessWithSomeDocuments_callsGetIdentification_updatesState() throws {
        let input = ConfirmApplicationActionInput(identificationUID: identificationUID)
        let expectedDocuments: [ContractDocument] = [
            .mock(id: "first"),
            .mock(id: "second")
        ]
        let expectedState = ConfirmApplicationState(
            hasQuitButton: true,
            documents: expectedDocuments.map { LoadableDocument(isLoading: false, document: $0) },
            hasTermsAndConditionsLink: true
        )
        
        let sut = makeSut()
        
        _ = sut.perform(input: input) { _ in }
        
        presenter.eventHandler?.loadDocuments()
        
        XCTAssertEqual(verificationService.getIdentificationCallsCount, 1)
        XCTAssertEqual(verificationService.getIdentificationArguments.last?.identificationUID, identificationUID)
        
        let getIdentificationCompletion = try XCTUnwrap(verificationService.getIdentificationArguments.last?.completionHandler)
        
        assertAsync { expectation in
            presenter.updateViewCompletion = {
                XCTAssertEqual(self.presenter.updateViewArguments.last, expectedState)
                
                expectation.fulfill()
            }

            getIdentificationCompletion(.success(Identification.mock(documents: expectedDocuments)))
        }
    }
    
    // MARK: - quit
    
    func test_quit_callsCallbackWithExpectedResult() {
        let input = ConfirmApplicationActionInput(identificationUID: identificationUID)
        
        let sut = makeSut()
        
        assertAsync { expectation in
            _ = sut.perform(input: input) { result in
                XCTAssertEqual(result, .quit)
                
                expectation.fulfill()
            }
            
            presenter.eventHandler?.quit()
        }
    }
    
    // MARK: - signDocuments
    
    func test_signDocuments_callsCallbackWithExpectedResult() {
        let input = ConfirmApplicationActionInput(identificationUID: identificationUID)
        
        let sut = makeSut()
        
        assertAsync { expectation in
            _ = sut.perform(input: input) { result in
                XCTAssertEqual(result, .confirmedApplication)
                
                expectation.fulfill()
            }
            
            presenter.eventHandler?.signDocuments()
        }
    }
    
    // MARK: - downloadDocument
    
    func test_downloadDocument_completesWithSuccess_callsDownloadAndSaveDocument_callsCallbackWithExpectedUrl() throws {
        let expectedUrl = URL(string: "https://solarisbank.de")!
        let documentId = "documentId"
        let document = ContractDocument.mock(id: documentId)
        let identification = Identification.mock(documents: [document])
        let input = ConfirmApplicationActionInput(identificationUID: identificationUID)

        let sut = makeSut()
        
        try assertAsync { expectation in
            _ = sut.perform(input: input) { result in
                XCTAssertEqual(result, .downloadDocument(url: expectedUrl))
                
                expectation.fulfill()
            }

            presenter.eventHandler?.loadDocuments()
            
            verificationService.getIdentificationArguments.last?.completionHandler(.success(identification))
            
            presenter.eventHandler?.downloadDocument(withId: documentId)
            
            XCTAssertEqual(verificationService.downloadAndSaveDocumentCallsCount, 1)
            XCTAssertEqual(verificationService.downloadAndSaveDocumentArguments.last?.id, documentId)
                    
            let downloadAndSaveCompletion = try XCTUnwrap(verificationService.downloadAndSaveDocumentArguments.last?.completion)
            
            downloadAndSaveCompletion(.success(expectedUrl))
        }
    }
    
    func test_downloadDocument_completesWithFailure_callsDownloadAndSaveDocument_doesNotCallCallback() throws {
        let expectedUrl = URL(string: "https://solarisbank.de")!
        let documentId = "documentId"
        let document = ContractDocument.mock(id: documentId)
        let identification = Identification.mock(documents: [document])
        let input = ConfirmApplicationActionInput(identificationUID: identificationUID)

        let sut = makeSut()
        
        try assertAsync { expectation in
            expectation.isInverted = true
            
            _ = sut.perform(input: input) { result in
                XCTAssertEqual(result, .downloadDocument(url: expectedUrl))
                
                expectation.fulfill()
            }

            presenter.eventHandler?.loadDocuments()
            
            verificationService.getIdentificationArguments.last?.completionHandler(.success(identification))
            
            presenter.eventHandler?.downloadDocument(withId: documentId)
            
            XCTAssertEqual(verificationService.downloadAndSaveDocumentCallsCount, 1)
            XCTAssertEqual(verificationService.downloadAndSaveDocumentArguments.last?.id, documentId)
                    
            let downloadAndSaveCompletion = try XCTUnwrap(verificationService.downloadAndSaveDocumentArguments.last?.completion)
            
            downloadAndSaveCompletion(.failure(.fileDownloadError(NSError.mock)))
        }
    }
    
    // MARK: - previewDocument
    
    func test_previewDocument_completesWithSuccess_callsDownloadAndSaveDocument_callsCallbackWithExpectedUrl() throws {
        let expectedUrl = URL(string: "https://solarisbank.de")!
        let documentId = "documentId"
        let document = ContractDocument.mock(id: documentId)
        let identification = Identification.mock(documents: [document])
        let input = ConfirmApplicationActionInput(identificationUID: "identification_uid")

        let sut = makeSut()
        
        try assertAsync { expectation in
            _ = sut.perform(input: input) { result in
                XCTAssertEqual(result, .previewDocument(url: expectedUrl))
                
                expectation.fulfill()
            }

            presenter.eventHandler?.loadDocuments()
            
            verificationService.getIdentificationArguments.last?.completionHandler(.success(identification))
            
            presenter.eventHandler?.previewDocument(withId: documentId)
            
            XCTAssertEqual(verificationService.downloadAndSaveDocumentCallsCount, 1)
            XCTAssertEqual(verificationService.downloadAndSaveDocumentArguments.last?.id, documentId)
                    
            let downloadAndSaveCompletion = try XCTUnwrap(verificationService.downloadAndSaveDocumentArguments.last?.completion)
            
            downloadAndSaveCompletion(.success(expectedUrl))
        }
    }
    
    func test_previewDocument_completesWithFailure_callsDownloadAndSaveDocument_doesNotCallCallback() throws {
        let expectedUrl = URL(string: "https://solarisbank.de")!
        let documentId = "documentId"
        let document = ContractDocument.mock(id: documentId)
        let identification = Identification.mock(documents: [document])
        let input = ConfirmApplicationActionInput(identificationUID: "identification_uid")

        let sut = makeSut()
        
        try assertAsync { expectation in
            expectation.isInverted = true
            
            _ = sut.perform(input: input) { result in
                XCTAssertEqual(result, .previewDocument(url: expectedUrl))
                
                expectation.fulfill()
            }

            presenter.eventHandler?.loadDocuments()
            
            verificationService.getIdentificationArguments.last?.completionHandler(.success(identification))
            
            presenter.eventHandler?.previewDocument(withId: documentId)
            
            XCTAssertEqual(verificationService.downloadAndSaveDocumentCallsCount, 1)
            XCTAssertEqual(verificationService.downloadAndSaveDocumentArguments.last?.id, documentId)
                    
            let downloadAndSaveCompletion = try XCTUnwrap(verificationService.downloadAndSaveDocumentArguments.last?.completion)
            
            downloadAndSaveCompletion(.failure(.fileDownloadError(NSError.mock)))
        }
    }
    
    private func makeSut() -> ConfirmApplicationAction<UpdateableShowableMock> {
        let sut = ConfirmApplicationAction(
            presenter: presenter,
            verificationService: verificationService
        )
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}

private class UpdateableShowableMock: UpdateableShowable {
    var eventHandler: ConfirmApplicationEventHandler?

    var toShowableCallsCount = 0
    var toShowableReturnValue = UIViewController()
    
    var updateViewCallsCount = 0
    var updateViewArguments: [ConfirmApplicationState] = []
    var updateViewCompletion: (() -> Void)?
    
    func toShowable() -> UIViewController {
        toShowableCallsCount += 1
        
        return toShowableReturnValue
    }
    
    func updateView(_ state: ConfirmApplicationState) {
        updateViewCallsCount += 1
        
        updateViewArguments.append(state)
        
        updateViewCompletion?()
    }
}
