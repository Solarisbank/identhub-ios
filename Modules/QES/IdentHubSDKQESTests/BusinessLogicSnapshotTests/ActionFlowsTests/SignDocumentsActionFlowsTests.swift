//
//  SignDocumentsActionFlowsTests.swift
//  IdentHubSDKQESTests
//
import XCTest
@testable import IdentHubSDKQES
@testable import IdentHubSDKCore
import IdentHubSDKTestBase

final class SignDocumentsActionFlowsTests: XCTestCase {
    typealias ViewController = UpdateableMock<SignDocumentsState, SignDocumentsEventHandler>

    private let uid = "someIdentId"
    private let mobileNumber = "+49 111 222 333"
    private let transactionId = "1234-5678"
    private let identificationToken = "someIdentId"

    private var recorder: TestRecorder!
    private var apiClient: APIClientMock!
    private var fileStorage: FileStorageMock!
    private var verificationService: VerificationServiceSpy!
    private var timerFactory: TimerFactoryMock!
    private var statusCheckService: StatusCheckServiceSpy!
    private var showable: ViewController!

    override func setUp() {
        super.setUp()
        
        recorder = TestRecorder()
        apiClient = APIClientMock(failUnexpectedRequests: true, recorder: recorder)
        fileStorage = FileStorageMock()
        showable = ViewController(recorder: recorder)
        
        let verificationServiceImpl = VerificationServiceImpl(
            apiClient: apiClient,
            fileStorage: fileStorage
        )
        
        verificationService = VerificationServiceSpy(
            verificationService: verificationServiceImpl,
            recorder: recorder
        )
        
        timerFactory = TimerFactoryMock()
        
        let statusCheckServiceImpl = StatusCheckServiceImpl(
            verificationService: verificationService,
            newCodeTimeout: 2,
            timerFactory: timerFactory
        )
        
        statusCheckService = StatusCheckServiceSpy(
            statusCheckService: statusCheckServiceImpl,
            recorder: recorder
        )
    }
    
    override func tearDown() {
        super.tearDown()
        
        recorder = nil
        apiClient = nil
        fileStorage = nil
        verificationService = nil
        timerFactory = nil
        statusCheckService = nil
        showable = nil
    }
    
    func testSuccessfulSigning() {
        let sut = makeSut()
        let input = SignDocumentsActionInput(identificationUID: uid, mobileNumber: nil)

        apiClient.expectSuccess(.mobileNumber, for: MobileNumberRequest())

        assertAsyncActionPeform(sut, with: input, expectedResult: .success(.identificationConfirmed(token: identificationToken))) {
            apiClient.expectSuccess(
                .signDocumentsAuthorize,
                for: try! DocumentsAuthorizeRequest(identificationUID: uid)
            )
            showable.requestNewCode()
            assertAsyncViewStateIn(showable) { $0.state == .codeAvailable }

            apiClient.expectSuccess(
                .signDocumentsConfirm,
                for: try! DocumentsTANRequest(identificationUID: uid, token: transactionId)
            )
            apiClient.expectSuccess(
                .identificationConfirmed,
                for: try! IdentificationRequest(identificationUID: uid)
            )
            showable.submitCodeAndSign(transactionId)
        }

        recorder.assert()
    }
    
    func testLoadingMobileNumberFailed() {
        let sut = makeSut()
        let input = SignDocumentsActionInput(identificationUID: uid, mobileNumber: nil)

        apiClient.expectError(.internalServerError, for: MobileNumberRequest())

        assertAsyncActionPeform(sut, with: input, expectedResult: .success(.identificationConfirmed(token: identificationToken))) {
            apiClient.expectSuccess(
                .signDocumentsAuthorize,
                for: try! DocumentsAuthorizeRequest(identificationUID: uid)
            )
            showable.requestNewCode()
            assertAsyncViewStateIn(showable) { $0.state == .codeAvailable }

            apiClient.expectSuccess(
                .signDocumentsConfirm,
                for: try! DocumentsTANRequest(identificationUID: uid, token: transactionId)
            )
            apiClient.expectSuccess(
                .identificationConfirmed,
                for: try! IdentificationRequest(identificationUID: uid)
            )
            showable.submitCodeAndSign(transactionId)
        }

        recorder.assert()
    }
    
    func testQuit() {
        let sut = makeSut()
        let input = SignDocumentsActionInput(identificationUID: uid, mobileNumber: mobileNumber)

        assertAsyncActionPeform(sut, with: input, expectedResult: .success(.quit)) {
            showable.quit()
        }

        recorder.assert()
    }
    
    func testRequestCodeFailed() {
        let sut = makeSut()
        let input = SignDocumentsActionInput(identificationUID: uid, mobileNumber: mobileNumber)

        _ = sut.perform(input: input) { _ in XCTFail("Unexpected result") }

        apiClient.expectError(
            .internalServerError,
            for: try! DocumentsAuthorizeRequest(identificationUID: uid)
        )
        showable.requestNewCode()
        
        assertAsyncViewStateIn(showable) { $0.state == .requestingCode }
        assertAsyncViewStateIn(showable) { $0.state == .codeUnavailable }

        recorder.assert()
    }

    func testStatusCheckFailed() {
        let sut = makeSut()
        let input = SignDocumentsActionInput(identificationUID: uid, mobileNumber: mobileNumber)

        assertAsyncActionPeform(sut, with: input, expectedResult: .failure(.authorizationFailed)) {
            apiClient.expectSuccess(
                .signDocumentsAuthorize,
                for: try! DocumentsAuthorizeRequest(identificationUID: uid)
            )
            showable.requestNewCode()
            assertAsyncViewStateIn(showable) { $0.state == .codeAvailable }

            apiClient.expectSuccess(
                .signDocumentsConfirm,
                for: try! DocumentsTANRequest(identificationUID: uid, token: transactionId)
            )
            apiClient.expectError(.authorizationFailed, for: try! IdentificationRequest(identificationUID: uid))
            showable.submitCodeAndSign(transactionId)
        }

        recorder.assert()
    }

    func testInvalidCode() {
        let sut = makeSut()
        let input = SignDocumentsActionInput(identificationUID: uid, mobileNumber: mobileNumber)

        _ = sut.perform(input: input) { _ in XCTFail("Unexpected result") }

        apiClient.expectSuccess(
            .signDocumentsAuthorize,
            for: try! DocumentsAuthorizeRequest(identificationUID: uid)
        )
        showable.requestNewCode()
        assertAsyncViewStateIn(showable) { $0.state == .codeAvailable }

        apiClient.expectError(
            .internalServerError,
            for: try! DocumentsTANRequest(identificationUID: uid, token: transactionId)
        )
        showable.submitCodeAndSign(transactionId)
        assertAsyncViewStateIn(showable) { $0.state == .codeInvalid }

        recorder.assert()
    }

    private func makeSut() -> SignDocumentsAction<ViewController> {
        let sut = SignDocumentsAction(
            viewController: showable,
            verificationService: verificationService,
            statusCheckService: statusCheckService
        )
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}

extension UpdateableMock: SignDocumentsEventHandler where EventHandler == SignDocumentsEventHandler {
    public func requestNewCode() {
        DispatchQueue.main.async {
            self.recorder?.record(event: .event, value: #function)
            self.eventHandler?.requestNewCode()
        }
    }
    
    public func submitCodeAndSign(_ code: String) {
        DispatchQueue.main.async {
            self.recorder?.record(event: .event, value: #function)
            self.eventHandler?.submitCodeAndSign(code)
        }
    }
    
    public func quit() {
        DispatchQueue.main.async {
            self.recorder?.record(event: .event, value: #function)
            self.eventHandler?.quit()
        }
    }
}
