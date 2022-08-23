//
//  ConfirmApplicationEventFlowsTest.swift
//  IdentHubSDKQESTests
//
@testable import IdentHubSDKQES
import XCTest
import IdentHubSDKCore
import IdentHubSDKTestBase

final class ConfirmApplicationEventFlowsTests: XCTestCase, FlowTest {
    typealias ViewController = UpdateableMock<ConfirmApplicationState, ConfirmApplicationEventHandler>

    private let uid = "someIdentId"
    private let documentUID = "someDocumentId"

    private var recorder: TestRecorder!
    private var apiClient: APIClientMock!
    private var verificationService: VerificationServiceSpy!

    override func setUp() {
        recorder = TestRecorder()
        apiClient = APIClientMock(failUnexpectedRequests: true, recorder: recorder)
        
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
    }

    func testSignDocuments() {
        let input = ConfirmApplicationInput(identificationUID: uid)

        assertFlow(input: input, expectedOutput: .confirmedApplication) { showable in
            apiClient.expectSuccess(.identificationNotConfirmed, for: try! IdentificationRequest(identificationUID: uid))
            showable.loadDocuments()

            showable.signDocuments()
        }

        recorder.assert()
    }
    
    func testPreviewDocument() {
        let input = ConfirmApplicationInput(identificationUID: uid)

        assertFlow(input: input) { showable in
            apiClient.expectSuccess(.identificationNotConfirmed, for: try! IdentificationRequest(identificationUID: uid))
            showable.loadDocuments()

            apiClient.expectSuccess(.bankDocument, for: try! DocumentDownloadRequest(documentUID: documentUID))
            showable.previewDocument(withId: documentUID)
            assertAsyncViewStateIn(showable) { viewState in
                viewState.documents.first?.isLoading == false
            }
        }

        recorder.assert()
    }
    
    func testDownloadDocument() {
        let input = ConfirmApplicationInput(identificationUID: uid)
        
        assertFlow(input: input) { showable in
            apiClient.expectSuccess(.identificationNotConfirmed, for: try! IdentificationRequest(identificationUID: uid))
            showable.loadDocuments()

            apiClient.expectSuccess(.bankDocument, for: try! DocumentDownloadRequest(documentUID: documentUID))
            showable.downloadDocument(withId: documentUID)
            assertAsyncViewStateIn(showable) { viewState in
                viewState.documents.first?.isLoading == false
            }
        }

        recorder.assert()
    }
    
    func testQuit() {
        let input = ConfirmApplicationInput(identificationUID: uid)
        
        assertFlow(input: input, expectedOutput: .quit) { showable in
            showable.quit()
        }

        recorder.assert()
    }

    func makeShowableWithSut(
        input: ConfirmApplicationInput,
        callback: @escaping ConfirmApplicationCallback = { _ in XCTFail("Unexpected callback") }
    ) -> ViewController {
        let showable = ViewController(recorder: recorder)
        let sut = ConfirmApplicationEventHandlerImpl<ViewController>(
            verificationService: verificationService,
            documentExporter: DocumentExporterMock(recorder: recorder),
            input: input,
            callback: callback
            )
        showable.eventHandler = sut
        sut.updatableView = showable

        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(showable)

        return showable
    }
}

extension UpdateableMock: ConfirmApplicationEventHandler where EventHandler == ConfirmApplicationEventHandler {

    public func loadDocuments() {
        self.recorder?.record(event: .event, in: #function)
        self.eventHandler?.loadDocuments()
    }
    
    public func signDocuments() {
        DispatchQueue.main.async {
            self.recorder?.record(event: .event, in: #function)
            self.eventHandler?.signDocuments()
        }
    }
    
    public func previewDocument(withId id: String) {
        DispatchQueue.main.async {
            self.recorder?.record(event: .event, in: #function, arguments: id)
            self.eventHandler?.previewDocument(withId: id)
        }
    }
    
    public func downloadDocument(withId id: String) {
        DispatchQueue.main.async {
            self.recorder?.record(event: .event, in: #function, arguments: id)
            self.eventHandler?.downloadDocument(withId: id)
        }
    }
    
    public func quit() {
        DispatchQueue.main.async {
            self.recorder?.record(event: .event, in: #function)
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
