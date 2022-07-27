//
//  ConfirmApplicationActionFlowsTest.swift
//  IdentHubSDKQESTests
//
@testable import IdentHubSDKQES
import XCTest
import IdentHubSDKCore
import IdentHubSDKTestBase

final class ConfirmApplicationActionFlowsTests: XCTestCase {
    typealias ViewController = UpdateableMock<ConfirmApplicationState, ConfirmApplicationEventHandler>

    private let uid = "someIdentId"
    private let documentUID = "someDocumentId"

    private var recorder: TestRecorder!
    private var apiClient: APIClientMock!
    private var verificationService: VerificationServiceSpy!
    private var showable: ViewController!

    override func setUp() {
        recorder = TestRecorder()
        apiClient = APIClientMock(failUnexpectedRequests: true, recorder: recorder)
        showable = ViewController(recorder: recorder)
        
        let verificationServiceImpl = VerificationServiceImpl(
            apiClient: apiClient,
            fileStorage: FileStorageMock()
        )
        
        verificationService = VerificationServiceSpy(
            verificationService: verificationServiceImpl,
            recorder: recorder
        )
    }
    
    override func tearDown() {
        super.tearDown()
        
        recorder = nil
        apiClient = nil
        verificationService = nil
        showable = nil
    }

    func testSignDocuments() {
        let sut = makeSut()
        let input = ConfirmApplicationActionInput(identificationUID: uid)

        assertAsyncActionPeform(sut, with: input, expectedResult: .confirmedApplication) {
            apiClient.expectSuccess(.identificationNotConfirmed, for: try! IdentificationRequest(identificationUID: uid))
            showable.loadDocuments()

            showable.signDocuments()
        }

        recorder.assert()
    }
    
    func testPreviewDocument() {
        let sut = makeSut()
        let input = ConfirmApplicationActionInput(identificationUID: uid)

        assertAsyncActionPeform(sut, with: input, expectedResult: .previewDocument(url: RequestFileMock.bankDocument.url)) {
            apiClient.expectSuccess(.identificationNotConfirmed, for: try! IdentificationRequest(identificationUID: uid))
            showable.loadDocuments()

            apiClient.expectSuccess(.bankDocument, for: try! DocumentDownloadRequest(documentUID: documentUID))
            showable.previewDocument(withId: documentUID)
        }

        recorder.assert()
    }
    
    func testDownloadDocument() {
        let sut = makeSut()
        let input = ConfirmApplicationActionInput(identificationUID: uid)

        assertAsyncActionPeform(sut, with: input, expectedResult: .downloadDocument(url: RequestFileMock.bankDocument.url)) {
            apiClient.expectSuccess(.identificationNotConfirmed, for: try! IdentificationRequest(identificationUID: uid))
            showable.loadDocuments()

            apiClient.expectSuccess(.bankDocument, for: try! DocumentDownloadRequest(documentUID: documentUID))
            showable.downloadDocument(withId: documentUID)
        }

        recorder.assert()
    }
    
    func testQuit() {
        let sut = makeSut()
        let input = ConfirmApplicationActionInput(identificationUID: uid)

        assertAsyncActionPeform(sut, with: input, expectedResult: .quit) {
            showable.quit()
        }

        recorder.assert()
    }

    // TODO: Scenarios to review - at the moment we are doing nothing in these cases
    // IdentificationRequest failed - we can't display documents, sign button is disabled
    // DocumentDownloadRequest failed (preview or download) - we are not doing anything - infinite loading on a document is displayed
    
    private func makeSut() -> ConfirmApplicationAction<ViewController> {
        let sut = ConfirmApplicationAction(
            presenter: showable,
            verificationService: verificationService
        )
        trackForMemoryLeaks(sut)
        return sut
    }
}

extension UpdateableMock: ConfirmApplicationEventHandler where EventHandler == ConfirmApplicationEventHandler {

    public func loadDocuments() {
        recorder?.record(event: .event, value: #function)
        eventHandler?.loadDocuments()
    }
    
    public func signDocuments() {
        DispatchQueue.main.async {
            self.recorder?.record(event: .event, value: #function)
            self.eventHandler?.signDocuments()
        }
    }
    
    public func previewDocument(withId id: String) {
        DispatchQueue.main.async {
            self.recorder?.record(event: .event, value: #function)
            self.eventHandler?.previewDocument(withId: id)
        }
    }
    
    public func downloadDocument(withId id: String) {
        DispatchQueue.main.async {
            self.recorder?.record(event: .event, value: #function)
            self.eventHandler?.downloadDocument(withId: id)
        }
    }
    
    public func quit() {
        DispatchQueue.main.async {
            self.recorder?.record(event: .event, value: #function)
            self.eventHandler?.quit()
        }
    }
}

extension ContractDocument: CustomStringConvertible {
    public var description: String {
        "ContractDocument(\(id))"
    }
}

extension LoadableDocument: CustomStringConvertible {
    public var description: String {
        "LoadableDocument(\(document), isLoading: \(isLoading))"
    }
}
