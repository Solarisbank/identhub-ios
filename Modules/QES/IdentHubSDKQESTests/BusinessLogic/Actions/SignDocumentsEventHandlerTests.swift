//
//  SignDocumentsEventHandlerTests.swift
//  IdentHubSDKQESTests
//

@testable import IdentHubSDKQES
@testable import IdentHubSDKCore
import XCTest
import IdentHubSDKTestBase

final class SignDocumentsEventHandlerTests: XCTestCase {
    private var verificationService: VerificationServiceMock!
    private var statusCheckService: StatusCheckServiceMock!
    
    private let identificationUID = "identification_uid"
    private let code = "012345"
    
    override func setUp() {
        super.setUp()
        
        verificationService = VerificationServiceMock()
        statusCheckService = StatusCheckServiceMock()
    }
    
    override func tearDown() {
        super.tearDown()
        
        verificationService = nil
        statusCheckService = nil
    }
    
    // MARK: - perform
    
    func test_perform_mobileNumberIsNil_callsGetMobileNumber_doesNotCallCallback() {
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedState = SignDocumentsState.mock()
        let showable = UpdateableShowableMock()

        assertAsync { updateViewExpectation in
            showable.assertLastStateUpdate(expectedState, fulfill: updateViewExpectation)

            assertAsync { callbackExpectation in
                callbackExpectation.isInverted = true
                
                makeSut(for: showable, input: input) { _ in
                    callbackExpectation.fulfill()
                }
            }
            XCTAssertNotNil(showable.eventHandler)
            XCTAssertEqual(verificationService.getMobileNumberCallsCount, 1)
        }
    }
    
    func test_perform_mobileNumberIsNotNil_doesNotCallGetMobileNumber_doesNotCallCallback() {
        let mobileNumber = "555555555"
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: mobileNumber)
        let expectedState = SignDocumentsState.mock(mobileNumber: mobileNumber)
        let showable = UpdateableShowableMock()

        assertAsync { updateViewExpectation in
            showable.assertLastStateUpdate(expectedState, fulfill: updateViewExpectation)

            assertAsync { callbackExpectation in
                callbackExpectation.isInverted = true
                
                makeSut(for: showable, input: input) { _ in
                    callbackExpectation.fulfill()
                }
            }
        }
        
        XCTAssertNotNil(showable.eventHandler)
        XCTAssertEqual(verificationService.getMobileNumberCallsCount, 0)
    }
    
    func test_perform_mobileNumberIsNil_callGetMobileNumberSucceeds_updatesStateWithExpectedValue() throws {
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedMobileNumber = "555555555"
        let expectedState = SignDocumentsState.mock(mobileNumber: expectedMobileNumber)
        let showable = makeViewControllerWithSut(input: input)

        try assertAsync { updateViewExpectation in
            showable.assertLastStateUpdate(expectedState, fulfill: updateViewExpectation)

            let getMobileNumberArgumentsCompletion = try XCTUnwrap(verificationService.getMobileNumberArguments.last)
            
            getMobileNumberArgumentsCompletion(.success(.init(id: nil, number: expectedMobileNumber, verified: true)))
        }
        
        XCTAssertEqual(verificationService.getMobileNumberCallsCount, 1)
    }
    
    func test_perform_mobileNumberIsNil_callGetMobileNumberFails_doesNotUpdateState() throws {
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedState = SignDocumentsState.mock()
        let showable = makeViewControllerWithSut(input: input)

        try assertAsync { updateViewExpectation in
            updateViewExpectation.isInverted = true
            
            showable.updateViewCompletion = {
                updateViewExpectation.fulfill()
            }
            
            let getMobileNumberArgumentsCompletion = try XCTUnwrap(verificationService.getMobileNumberArguments.last)
            
            getMobileNumberArgumentsCompletion(.failure(.init(.unknownError)))
        }
        
        XCTAssertEqual(verificationService.getMobileNumberCallsCount, 1)
        XCTAssertEqual(showable.updateViewArguments.last, expectedState)
    }
    
    // MARK: - quit
    
    func test_quit_callsCallbackWithExpectedResult() {
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: nil)

        assertAsync { expectation in
            let showable = makeViewControllerWithSut(input: input) { result in
                XCTAssertResultIsSuccess(result) { value in
                    XCTAssertEqual(value, .quit)
                }
                
                expectation.fulfill()
            }
            
            showable.eventHandler?.quit()
        }
    }
    
    // MARK: - requestNewCode
    
    func test_requestNewCode_callsSetupNewCodeTimer_callsAuthorizeDocuments() {
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: nil)
        let showable = makeViewControllerWithSut(input: input)

        showable.eventHandler?.requestNewCode()
        
        XCTAssertEqual(statusCheckService.setupNewCodeTimerCallsCount, 1)
        XCTAssertEqual(verificationService.authorizeDocumentsCallsCount, 1)
        XCTAssertEqual(verificationService.authorizeDocumentsArguments.last?.identificationUID, identificationUID)
        
        assertAsync { expectation in
            showable.updateViewCompletion = {
                expectation.fulfill()
            }
        }
    }
    
    func test_requestNewCode_setupNewCodeTimerCompletes_stateIsUpdated() throws {
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedNewCodeRemainingTime = 10
        let expectedState = SignDocumentsState.mock(newCodeRemainingTime: expectedNewCodeRemainingTime)
        let showable = makeViewControllerWithSut(input: input)

        showable.eventHandler?.requestNewCode()
        
        assertAsync { expectation in
            showable.updateViewCompletion = {
                expectation.fulfill()
            }
        }
        
        try assertAsync { expectation in
            showable.assertLastStateUpdate(expectedState, fulfill: expectation)

            let setupNewCodeTimerCompletion = try XCTUnwrap(statusCheckService.setupNewCodeTimerArguments.last)
            
            setupNewCodeTimerCompletion(expectedNewCodeRemainingTime)
        }
    }
    
    func test_requestNewCode_authorizeDocumentsCompletesWithSuccessWithTransactionId_stateIsUpdated() throws {
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedTransactionId = "transaction_id"
        let expectedState = SignDocumentsState.mock(state: .codeAvailable, transactionId: expectedTransactionId)
        let showable = makeViewControllerWithSut(input: input)

        showable.eventHandler?.requestNewCode()
        
        assertAsync { expectation in
            showable.updateViewCompletion = {
                expectation.fulfill()
            }
        }
        
        try assertAsync { expectation in
            showable.updateViewCompletion = { [weak showable] in
                XCTAssertEqual(showable?.updateViewArguments.last, expectedState)
                
                expectation.fulfill()
            }

            let authorizeDocumentsCompletion = try XCTUnwrap(verificationService.authorizeDocumentsArguments.last?.completionHandler)
            
            authorizeDocumentsCompletion(.success(Identification.mock(referenceToken: expectedTransactionId)))
        }
    }
    
    func test_requestNewCode_authorizeDocumentsCompletesWithSuccessWithoutTransactionId_stateIsUpdated() throws {
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedState = SignDocumentsState.mock(state: .codeAvailable)
        let showable = makeViewControllerWithSut(input: input)

        showable.eventHandler?.requestNewCode()
        
        assertAsync { expectation in
            showable.updateViewCompletion = {
                expectation.fulfill()
            }
        }
        
        try assertAsync { expectation in
            showable.assertLastStateUpdate(expectedState, fulfill: expectation)

            let authorizeDocumentsCompletion = try XCTUnwrap(verificationService.authorizeDocumentsArguments.last?.completionHandler)
            
            authorizeDocumentsCompletion(.success(Identification.mock(referenceToken: nil)))
        }
    }
    
    func test_requestNewCode_authorizeDocumentsCompletesWithFailure_stateIsUpdated_callsInvalidateNewCodeTimer() throws {
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedState = SignDocumentsState.mock(state: .codeUnavailable)
        let showable = makeViewControllerWithSut(input: input)

        showable.eventHandler?.requestNewCode()
        
        assertAsync { expectation in
            showable.updateViewCompletion = {
                expectation.fulfill()
            }
        }
        
        XCTAssertEqual(statusCheckService.invalidateNewCodeTimerCallsCount, 0)
        
        try assertAsync { expectation in
            showable.assertLastStateUpdate(expectedState, fulfill: expectation)

            let authorizeDocumentsCompletion = try XCTUnwrap(verificationService.authorizeDocumentsArguments.last?.completionHandler)
            
            authorizeDocumentsCompletion(.failure(.init(.unknownError)))
        }
        
        XCTAssertEqual(statusCheckService.invalidateNewCodeTimerCallsCount, 1)
    }
    
    // MARK: - submitCodeAndSign
    
    func test_submitCodeAndSign_callsInvalidateNewCodeTimer_callsVerifyDocumentsTANWithExpectedArguments() {
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: nil)
        let showable = makeViewControllerWithSut(input: input)

        showable.eventHandler?.submitCodeAndSign(code)
        
        XCTAssertEqual(statusCheckService.invalidateNewCodeTimerCallsCount, 1)
        XCTAssertEqual(verificationService.verifyDocumentsTANCallsCount, 1)
        XCTAssertEqual(verificationService.verifyDocumentsTANArguments.last?.identificationUID, identificationUID)
        XCTAssertEqual(verificationService.verifyDocumentsTANArguments.last?.token, code)

        assertAsync { expectation in
            showable.updateViewCompletion = {
                expectation.fulfill()
            }
        }
    }
    
    func test_submitCodeAndSign_verifyDocumentsTANCompletesWithSuccess_statusConfirmed_updatesState_callsSetupStatusVerificationTimer() throws {
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedState = SignDocumentsState.mock(state: .processingIdentfication)
        let showable = makeViewControllerWithSut(input: input)

        showable.eventHandler?.submitCodeAndSign(code)
        
        assertAsync { expectation in
            showable.updateViewCompletion = {
                expectation.fulfill()
            }
        }
        
        try assertAsync { expectation in
            expectation.expectedFulfillmentCount = 2
            
            showable.assertLastStateUpdate(expectedState, fulfill: expectation)

            statusCheckService.setupStatusVerificationTimerCompletion = {
                XCTAssertEqual(self.statusCheckService.setupStatusVerificationTimerArguments.last?.identificationUID, self.identificationUID)
                
                expectation.fulfill()
            }

            let verifyDocumentsTANCompletion = try XCTUnwrap(verificationService.verifyDocumentsTANArguments.last?.completionHandler)
            
            verifyDocumentsTANCompletion(.success(.mock(status: .confirmed)))
        }
    }
    
    func test_submitCodeAndSign_verifyDocumentsTANCompletesWithSuccess_statusConfirmed_setupStatusVerificationTimerCompletesWithConfirmed_updatesState_callsCallback() throws {
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedToken = "token"
        let expectedState = SignDocumentsState(state: .identificationSuccessful)
        
        try assertAsync { callbackExpectation in
            let showable = makeViewControllerWithSut(input: input) { result in
                XCTAssertResultIsSuccess(result) { value in
                    XCTAssertEqual(value, .identificationConfirmed(token: expectedToken))
                }
                
                callbackExpectation.fulfill()
            }
            
            showable.eventHandler?.submitCodeAndSign(code)
            
            try assertAsync { expectation in
                statusCheckService.setupStatusVerificationTimerCompletion = {
                    expectation.fulfill()
                }

                let verifyDocumentsTANCompletion = try XCTUnwrap(verificationService.verifyDocumentsTANArguments.last?.completionHandler)
                
                verifyDocumentsTANCompletion(.success(.mock(status: .confirmed)))
            }
            
            try assertAsync { expectation in
                showable.assertLastStateUpdate(expectedState, fulfill: expectation)

                let setupStatusVerificationTimerCallback = try XCTUnwrap(statusCheckService.setupStatusVerificationTimerArguments.last?.callback)
                
                setupStatusVerificationTimerCallback(.success(expectedToken))
            }
        }
    }
    
    func test_submitCodeAndSign_verifyDocumentsTANCompletesWithSuccess_statusConfirmed_setupStatusVerificationTimerCompletesWithSucceeded_updatesState_callsCallback() throws {
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedToken = "token"
        let expectedState = SignDocumentsState(state: .identificationSuccessful)

        try assertAsync(timeout: 0.3) { callbackExpectation in
            callbackExpectation.isInverted = true
            let showable = makeViewControllerWithSut(input: input) { result in
                XCTAssertResultIsSuccess(result) { value in
                    XCTAssertEqual(value, .identificationConfirmed(token: expectedToken))
                }
            }
            
            showable.eventHandler?.submitCodeAndSign(code)
            
            try assertAsync { expectation in
                statusCheckService.setupStatusVerificationTimerCompletion = {
                    expectation.fulfill()
                }

                let verifyDocumentsTANCompletion = try XCTUnwrap(verificationService.verifyDocumentsTANArguments.last?.completionHandler)
                
                verifyDocumentsTANCompletion(.success(.mock(status: .confirmed)))
            }
            
            try assertAsync { expectation in
                showable.assertLastStateUpdate(expectedState, fulfill: expectation)

                let setupStatusVerificationTimerCallback = try XCTUnwrap(statusCheckService.setupStatusVerificationTimerArguments.last?.callback)
                
                setupStatusVerificationTimerCallback(.success(expectedToken))
            }
        }
    }
    
    func test_submitCodeAndSign_verifyDocumentsTANCompletesWithSuccess_statusConfirmed_setupStatusVerificationTimerCompletesWithFailure_doesNotUpdatesState_callsCallback() throws {
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedError = APIError.unknownError
        
        try assertAsync(timeout: 0.3) { callbackExpectation in
            let showable = makeViewControllerWithSut(input: input) { result in
                XCTAssertResultIsFailure(result) { error in
                    XCTAssertEqual(error, expectedError)
                }
                
                callbackExpectation.fulfill()
            }
            
            showable.eventHandler?.submitCodeAndSign(code)
            
            try assertAsync { expectation in
                statusCheckService.setupStatusVerificationTimerCompletion = {
                    expectation.fulfill()
                }

                let verifyDocumentsTANCompletion = try XCTUnwrap(verificationService.verifyDocumentsTANArguments.last?.completionHandler)
                
                verifyDocumentsTANCompletion(.success(.mock(status: .confirmed)))
            }
            
            try assertAsync { expectation in
                expectation.isInverted = true
                
                showable.updateViewCompletion = {
                    expectation.fulfill()
                }
                
                let setupStatusVerificationTimerCallback = try XCTUnwrap(statusCheckService.setupStatusVerificationTimerArguments.last?.callback)
                
                setupStatusVerificationTimerCallback(.failure(expectedError))
            }
        }
    }
    
    
    func test_submitCodeAndSign_verifyDocumentsTANCompletesWithSuccess_statusOtherThanConfirmed_callsInvalidateNewCodeTimer_updatesState_doesNotCallCallback() throws {
        let statuses: [Status] = Status.allCases.filter { $0 != .confirmed }
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedState = SignDocumentsState.mock(state: .codeInvalid)

        try statuses.forEach { status in
            statusCheckService = StatusCheckServiceMock()
            let showable = UpdateableShowableMock()
            verificationService = VerificationServiceMock()
            
            try assertAsync(timeout: 1.0) { callbackExpectation in
                callbackExpectation.isInverted = true
                makeSut(for: showable, input: input) { _ in
                    callbackExpectation.fulfill()
                }
                
                showable.eventHandler?.submitCodeAndSign(code)
                
                assertAsync { expectation in
                    showable.updateViewCompletion = {
                        expectation.fulfill()
                    }
                }
                
                let invalidateNewCodeTimerCallsCount = statusCheckService.invalidateNewCodeTimerCallsCount
                
                try assertAsync(timeout: 0.3) { expectation in
                    expectation.expectedFulfillmentCount = 2
                    
                    statusCheckService.invalidateNewCodeTimerCompletion = {
                        expectation.fulfill()
                    }
                    
                    showable.assertLastStateUpdate(expectedState, fulfill: expectation)

                    let verifyDocumentsTANCompletion = try XCTUnwrap(verificationService.verifyDocumentsTANArguments.last?.completionHandler)
                    
                    verifyDocumentsTANCompletion(.success(.mock(status: status)))
                }
                
                XCTAssertEqual(statusCheckService.invalidateNewCodeTimerCallsCount, invalidateNewCodeTimerCallsCount + 1)
            }
        }
    }
    
    func test_submitCodeAndSign_verifyDocumentsTANCompletesWithFailure_callsInvalidateNewCodeTimer_updatesState_doesNotCallCallback() throws {
        let input = SignDocumentsInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedState = SignDocumentsState.mock(state: .codeInvalid)

        try assertAsync(timeout: 1.0) { callbackExpectation in
            callbackExpectation.isInverted = true
            let showable = makeViewControllerWithSut(input: input) { _ in
                callbackExpectation.fulfill()
            }
            
            showable.eventHandler?.submitCodeAndSign(code)
            
            assertAsync { expectation in
                showable.updateViewCompletion = {
                    expectation.fulfill()
                }
            }
            
            let invalidateNewCodeTimerCallsCount = statusCheckService.invalidateNewCodeTimerCallsCount
            
            try assertAsync(timeout: 0.3) { expectation in
                expectation.expectedFulfillmentCount = 2
                
                statusCheckService.invalidateNewCodeTimerCompletion = {
                    expectation.fulfill()
                }
                
                showable.assertLastStateUpdate(expectedState, fulfill: expectation)

                let verifyDocumentsTANCompletion = try XCTUnwrap(verificationService.verifyDocumentsTANArguments.last?.completionHandler)
                
                verifyDocumentsTANCompletion(.failure(.init(.unknownError)))
            }
            
            XCTAssertEqual(statusCheckService.invalidateNewCodeTimerCallsCount, invalidateNewCodeTimerCallsCount + 1)
        }
    }
    
    private func makeViewControllerWithSut(input: SignDocumentsInput, callback: @escaping (Result<SignDocumentsOutput, APIError>) -> Void = { _ in }) -> UpdateableShowableMock {
        let showable = UpdateableShowableMock()
        makeSut(for: showable, input: input, callback: callback)
        return showable
    }
    
    private func makeSut(
        for showable: UpdateableShowableMock,
        input: SignDocumentsInput,
        callback: @escaping (Result<SignDocumentsOutput, APIError>) -> Void = { _ in XCTFail("Unexpected callback") }
    ) {
        let sut = SignDocumentsEventHandlerImpl<UpdateableShowableMock>(
            verificationService: verificationService,
            statusCheckService: statusCheckService,
            input: input,
            callback: callback
        )
        showable.eventHandler = sut
        sut.updatableView = showable
        
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(showable)
    }
}

private class UpdateableShowableMock: UpdateableShowable {
    var eventHandler: SignDocumentsEventHandler?

    var toShowableCallsCount = 0
    var toShowableReturnValue = UIViewController()
    
    var updateViewCallsCount = 0
    var updateViewArguments: [SignDocumentsState] = []
    var updateViewCompletion: (() -> Void)?
    
    func toShowable() -> UIViewController {
        toShowableCallsCount += 1
        
        return toShowableReturnValue
    }
    
    func updateView(_ state: SignDocumentsState) {
        updateViewCallsCount += 1
        
        updateViewArguments.append(state)
        
        updateViewCompletion?()
    }
}

private extension SignDocumentsState {
    static func mock(
        mobileNumber: String? = nil,
        state: SignDocumentsState.State = .requestingCode,
        newCodeRemainingTime: Int = 0,
        transactionId: String? = nil
    ) -> SignDocumentsState {
        SignDocumentsState(
            mobileNumber: mobileNumber,
            state: state,
            newCodeRemainingTime: newCodeRemainingTime,
            transactionId: transactionId
        )
    }
}

private extension UpdateableShowableMock {
    func assertLastStateUpdate(_ expectedState: ViewState, fulfill expectation: XCTestExpectation) {
        updateViewCompletion = { [weak self] in
            XCTAssertEqual(self?.updateViewArguments.last, expectedState)
            
            expectation.fulfill()
        }
    }
}
