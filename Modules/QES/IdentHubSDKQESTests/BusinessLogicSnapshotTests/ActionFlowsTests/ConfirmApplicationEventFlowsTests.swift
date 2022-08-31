//
//  ConfirmApplicationEventFlowsTest.swift
//  IdentHubSDKQESTests
//
@testable import IdentHubSDKQES
import XCTest
import IdentHubSDKCore
import IdentHubSDKTestBase

final class ConfirmApplicationEventFlowsTests: XCTestCase, FlowTest {
    typealias ViewController = UpdateableMock<ConfirmApplicationState, ConfirmApplicationEvent>

    private let uid = "someIdentId"
    private let documentUID = "someDocumentId"

    private var recorder: TestRecorder!
    private var apiClient: APIClientMock!
    private var verificationService: VerificationServiceSpy!
    private var alertsService: AlertsServiceMock!

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

        alertsService = AlertsServiceMock(recorder: recorder)
    }
    
    override func tearDown() {
        super.tearDown()
        
        recorder = nil
        apiClient = nil
        verificationService = nil
        alertsService = nil
    }

    func testSignDocuments() {
        let input = ConfirmApplicationInput(identificationUID: uid)

        assertFlow(input: input, expectedOutput: .confirmedApplication) { showable in
            apiClient.expectSuccess(.identificationNotConfirmed, for: try! IdentificationRequest(identificationUID: uid))
            showable.sendEvent(.loadDocuments)
            assertAsyncViewStateIn(showable) { state in
                state.documents.isNotEmpty()
            }
            showable.sendEvent(.signDocuments)
        }

        recorder.assert()
    }
    
    func testPreviewDocument() {
        let input = ConfirmApplicationInput(identificationUID: uid)

        assertFlow(input: input) { showable in
            apiClient.expectSuccess(.identificationNotConfirmed, for: try! IdentificationRequest(identificationUID: uid))
            showable.sendEvent(.loadDocuments)
            assertAsyncViewStateIn(showable) { state in
                state.documents.isNotEmpty()
            }

            apiClient.expectSuccess(.bankDocument, for: try! DocumentDownloadRequest(documentUID: documentUID))
            showable.sendEvent(.previewDocument(withId: documentUID))
        }

        recorder.assert()
    }

    func testPreviewDocumentFailure() {
        let input = ConfirmApplicationInput(identificationUID: uid)

        assertFlow(input: input) { showable in
            apiClient.expectSuccess(.identificationNotConfirmed, for: try! IdentificationRequest(identificationUID: uid))
            showable.sendEvent(.loadDocuments)

            apiClient.expectError(.unknownError, for: try! DocumentDownloadRequest(documentUID: documentUID))
            showable.sendEvent(.previewDocument(withId: documentUID))
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
            showable.sendEvent(.loadDocuments)
            assertAsyncViewStateIn(showable) { state in
                state.documents.isNotEmpty()
            }

            apiClient.expectSuccess(.bankDocument, for: try! DocumentDownloadRequest(documentUID: documentUID))
            showable.sendEvent(.downloadDocument(withId: documentUID))
        }

        recorder.assert()
    }

    func testDownloadDocumentFailure() {
        let input = ConfirmApplicationInput(identificationUID: uid)

        assertFlow(input: input) { showable in
            apiClient.expectSuccess(.identificationNotConfirmed, for: try! IdentificationRequest(identificationUID: uid))
            showable.sendEvent(.loadDocuments)

            apiClient.expectError(.unknownError, for: try! DocumentDownloadRequest(documentUID: documentUID))
            showable.sendEvent(.downloadDocument(withId: documentUID))

            assertAsyncViewStateIn(showable) { viewState in
                viewState.documents.first?.isLoading == false
            }
        }

        recorder.assert()
    }
    
    func testQuit() {
        let input = ConfirmApplicationInput(identificationUID: uid)
        
        assertFlow(input: input, expectedOutput: .quit) { showable in
            showable.sendEvent(.quit)
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
            alertsService: alertsService,
            documentExporter: DocumentExporterMock(recorder: recorder),
            input: input,
            callback: callback
            )
        showable.eventHandler = sut.asAnyEventHandler()
        sut.updatableView = showable

        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(showable)

        return showable
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
