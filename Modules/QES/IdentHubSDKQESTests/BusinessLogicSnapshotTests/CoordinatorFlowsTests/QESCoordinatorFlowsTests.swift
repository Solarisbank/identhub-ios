//
//  QESCoordinatorFlowsTests.swift
//  IdentHubSDKQESTests
//
@testable import IdentHubSDKQES
import XCTest
import IdentHubSDKCore
import IdentHubSDKTestBase
import CloudKit

final class QESCoordinatorFlowsTests: XCTestCase {
    var recorder: TestRecorder!
    var apiClient: APIClientMock!
    var verificationService: VerificationService!
    var actionFactory: ActionFactoryMock!
    var actionPerformer: ActionPerformer!

    override func setUp() {
        recorder = TestRecorder()
        apiClient = APIClientMock(failUnexpectedRequests: true, recorder: recorder)
        verificationService = VerificationServiceImpl(
            apiClient: apiClient,
            fileStorage: FileStorageMock()
        )
        actionFactory = ActionFactoryMock(testRecorder: recorder)
        actionPerformer = ActionPerformer()
    }
    
    func testConfirmApplicationAndSignDocuments() {
        let sut: QESCoordinatorImpl = makeSut()
        let input = QESInput(
            step: .confirmAndSignDocuments,
            identificationUID: "uid",
            mobileNumber: "+49 111 222 333"
        )
        
        assertAsyncCoordinatorStart(sut, with: input, expectedResult: .success(.identificationConfirmed(identificationToken: "XXX"))) {
            actionFactory.confirmApplicationAction.mockCallback(with: .previewDocument(url: .mock()))
            actionFactory.previewDocumentAction.mockCallback(with: true, isFinished: true)
            actionFactory.previewDocumentAction = nil

            actionFactory.confirmApplicationAction.mockCallback(with: .downloadDocument(url: .mock()))
            actionFactory.downloadDocumentAction.mockCallback(with: true, isFinished: true)
            actionFactory.downloadDocumentAction = nil
            

            actionFactory.confirmApplicationAction.mockCallback(with: .quit)
            actionFactory.quitAction.mockCallback(with: false, isFinished: true)
            actionFactory.quitAction = nil

            actionFactory.confirmApplicationAction.mockCallback(with: .confirmedApplication, isFinished: true)
            actionFactory.confirmApplicationAction = nil

            actionFactory.signDocumentsAction.mockCallback(with: .success(.identificationConfirmed(token: "XXX")), isFinished: true)
            actionFactory.signDocumentsAction = nil

            XCTAssertEqual(actionPerformer.actions.count, 0)
        }

        recorder.assert()
    }

    func testSignDocuments() {
        let sut = makeSut()
        let input = QESInput(
            step: .signDocuments,
            identificationUID: "uid",
            mobileNumber: "+49 111 222 333"
        )

        actionFactory.confirmApplicationAction = nil
        actionFactory.previewDocumentAction = nil
        actionFactory.downloadDocumentAction = nil

        assertAsyncCoordinatorStart(sut, with: input, expectedResult: .success(.identificationConfirmed(identificationToken: "XXX"))) {
            actionFactory.signDocumentsAction.mockCallback(with: .success(.quit))
            actionFactory.quitAction.mockCallback(with: false, isFinished: true)
            actionFactory.quitAction = nil

            actionFactory.signDocumentsAction.mockCallback(with: .success(.identificationConfirmed(token: "XXX")), isFinished: true)
            actionFactory.signDocumentsAction = nil
        }
        
        recorder.assert()
    }
    
    func testQuitConfirmApplication() {
        let sut: QESCoordinatorImpl = makeSut()
        let input = QESInput(
            step: .confirmAndSignDocuments,
            identificationUID: "uid",
            mobileNumber: "+49 111 222 333"
        )

        actionFactory.signDocumentsAction = nil
        actionFactory.previewDocumentAction = nil
        actionFactory.downloadDocumentAction = nil

        assertAsyncCoordinatorStart(sut, with: input, expectedResult: .success(.abort)) {
            actionFactory.confirmApplicationAction.mockCallback(with: .quit, isFinished: true)
            actionFactory.quitAction.mockCallback(with: true, isFinished: true)
            actionFactory.quitAction = nil
            actionFactory.confirmApplicationAction = nil

            XCTAssertEqual(actionPerformer.actions.count, 0)
        }

        recorder.assert()
    }

    func testQuitSignDocuments() {
        let sut: QESCoordinatorImpl = makeSut()
        let input = QESInput(
            step: .confirmAndSignDocuments,
            identificationUID: "uid",
            mobileNumber: "+49 111 222 333"
        )

        actionFactory.previewDocumentAction = nil
        actionFactory.downloadDocumentAction = nil

        assertAsyncCoordinatorStart(sut, with: input, expectedResult: .success(.abort)) {
            actionFactory.confirmApplicationAction.mockCallback(with: .confirmedApplication, isFinished: true)
            actionFactory.confirmApplicationAction = nil

            actionFactory.signDocumentsAction.mockCallback(with: .success(.quit), isFinished: true)
            actionFactory.quitAction.mockCallback(with: true, isFinished: true)
            actionFactory.quitAction = nil
            actionFactory.signDocumentsAction = nil
            XCTAssertEqual(actionPerformer.actions.count, 0)
        }

        recorder.assert()
    }

    private func makeSut() -> QESCoordinatorImpl {
        let sut = QESCoordinatorImpl(
            presenter: PresenterMock(),
            actionFactory: actionFactory,
            verificationService: verificationService,
            storage: StorageMock(),
            documentExporter: DocumentExporterService(),
            colors: ColorsImpl()
        )

        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(actionFactory.confirmApplicationAction)
        trackForMemoryLeaks(actionFactory.signDocumentsAction)
        trackForMemoryLeaks(actionFactory.quitAction)
        trackForMemoryLeaks(actionFactory.previewDocumentAction)
        trackForMemoryLeaks(actionFactory.downloadDocumentAction)

        return sut
    }
}

private extension URL {
    static func mock() -> URL {
        URL(string: "about")!
    }
}
