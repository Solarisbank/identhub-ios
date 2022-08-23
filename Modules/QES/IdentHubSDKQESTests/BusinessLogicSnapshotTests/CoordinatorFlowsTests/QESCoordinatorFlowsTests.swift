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
    var alertsService: AlertsServiceMock!
    var showableFactory: ShowableFactoryMock!

    override func setUp() {
        recorder = TestRecorder()
        apiClient = APIClientMock(failUnexpectedRequests: true, recorder: recorder)
        verificationService = VerificationServiceImpl(
            apiClient: apiClient,
            fileStorage: FileStorageMock()
        )
        alertsService = AlertsServiceMock(recorder: recorder)
        showableFactory = ShowableFactoryMock(testRecorder: recorder)
    }
    
    func testConfirmApplicationAndSignDocuments() {
        let sut: QESCoordinatorImpl = makeSut()
        let input = QESInput(
            step: .confirmAndSignDocuments,
            identificationUID: "uid",
            mobileNumber: "+49 111 222 333"
        )
        
        assertAsyncCoordinatorStart(sut, with: input, expectedResult: .success(.identificationConfirmed(identificationToken: "XXX"))) {
            showableFactory.confirmApplicationCallback?(.quit)
            alertsService.quitAlertCallback?(false)
            showableFactory.confirmApplicationCallback?(.confirmedApplication)

            showableFactory.signDocumentsCallback?(.success(.quit))
            alertsService.quitAlertCallback?(false)
            showableFactory.signDocumentsCallback?(.success(.identificationConfirmed(token: "XXX")))
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

        assertAsyncCoordinatorStart(sut, with: input, expectedResult: .success(.identificationConfirmed(identificationToken: "XXX"))) {
            showableFactory.signDocumentsCallback?(.success(.identificationConfirmed(token: "XXX")))
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

        assertAsyncCoordinatorStart(sut, with: input, expectedResult: .success(.abort)) {
            showableFactory.confirmApplicationCallback?(.quit)
            alertsService?.quitAlertCallback?(true)
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

        assertAsyncCoordinatorStart(sut, with: input, expectedResult: .success(.abort)) {
            showableFactory.confirmApplicationCallback?(.confirmedApplication)
            showableFactory.signDocumentsCallback?(.success(.quit))
            alertsService.quitAlertCallback?(true)
        }

        recorder.assert()
    }

    private func makeSut() -> QESCoordinatorImpl {
        let sut = QESCoordinatorImpl(
            presenter: PresenterMock(),
            showableFactory: showableFactory,
            verificationService: verificationService,
            alertsService: alertsService,
            storage: StorageMock(),
            colors: ColorsImpl()
        )

        trackForMemoryLeaks(sut)

        return sut
    }
}

private extension URL {
    static func mock() -> URL {
        URL(string: "about")!
    }
}
