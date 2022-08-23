//
//  SignDocumentsEventFlowsTests.swift
//  IdentHubSDKQESTests
//
import XCTest
@testable import IdentHubSDKQES
@testable import IdentHubSDKCore
import IdentHubSDKTestBase

final class SignDocumentsEventFlowsTests: XCTestCase, FlowTest {
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
        let input = SignDocumentsInput(identificationUID: uid, mobileNumber: nil)

        apiClient.expectSuccess(.mobileNumber, for: MobileNumberRequest())

        assertFlow(input: input, expectedOutput: .success(.identificationConfirmed(token: identificationToken))) { showable in

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
            assertAsyncViewStateIn(showable) { $0.state == .identificationSuccessful }
        }

        recorder.assert()
    }
    
    func testLoadingMobileNumberFailed() {
        let input = SignDocumentsInput(identificationUID: uid, mobileNumber: nil)

        apiClient.expectError(.internalServerError, for: MobileNumberRequest())

        assertFlow(input: input, expectedOutput: .success(.identificationConfirmed(token: identificationToken))) { showable in
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
            assertAsyncViewStateIn(showable) { $0.state == .identificationSuccessful }
        }

        recorder.assert()
    }
    
    func testQuit() {
        let input = SignDocumentsInput(identificationUID: uid, mobileNumber: mobileNumber)

        assertFlow(input: input, expectedOutput: .success(.quit)) { showable in
            showable.quit()
        }

        recorder.assert()
    }
    
    func testRequestCodeFailed() {
        let input = SignDocumentsInput(identificationUID: uid, mobileNumber: mobileNumber)
        assertFlow(input: input) { showable in
            apiClient.expectError(
                .internalServerError,
                for: try! DocumentsAuthorizeRequest(identificationUID: uid)
            )
            showable.requestNewCode()
        }

        recorder.assert()
    }

    func testStatusCheckFailed() {
        let input = SignDocumentsInput(identificationUID: uid, mobileNumber: mobileNumber)

        assertFlow(input: input, expectedOutput: .failure(.authorizationFailed)) { showable in
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
        let input = SignDocumentsInput(identificationUID: uid, mobileNumber: mobileNumber)

        assertFlow(input: input) { showable in
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
        }

        recorder.assert()
    }

    func makeShowableWithSut(input: SignDocumentsInput, callback: @escaping SignDocumentsCallback) -> ViewController {
        let showable = ViewController(recorder: recorder)
        let sut = SignDocumentsEventHandlerImpl<ViewController>(
            verificationService: verificationService,
            statusCheckService: statusCheckService,
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
