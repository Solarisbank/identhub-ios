//
//  SignDocumentsActionTests.swift
//  IdentHubSDKQESTests
//

@testable import IdentHubSDKQES
@testable import IdentHubSDKCore
import XCTest
import IdentHubSDKTestBase

final class SignDocumentsActionTests: XCTestCase {
    private var viewController: UpdateableShowableMock!
    private var verificationService: VerificationServiceMock!
    private var statusCheckService: StatusCheckServiceMock!
    
    private let identificationUID = "identification_uid"
    private let code = "012345"
    
    override func setUp() {
        super.setUp()
        
        viewController = UpdateableShowableMock()
        verificationService = VerificationServiceMock()
        statusCheckService = StatusCheckServiceMock()
    }
    
    override func tearDown() {
        super.tearDown()
        
        viewController = nil
        verificationService = nil
        statusCheckService = nil
    }
    
    // MARK: - perform
    
    func test_perform_mobileNumberIsNil_callsGetMobileNumber_doesNotCallCallback() {
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedState = SignDocumentsState.mock()
        
        let sut = makeSut()
        
        var result: Showable?
        
        assertAsync { updateViewExpectation in
            viewController.updateViewCompletion = {
                XCTAssertEqual(self.viewController.updateViewArguments.last, expectedState)
                
                updateViewExpectation.fulfill()
            }
            
            assertAsync { callbackExpectation in
                callbackExpectation.isInverted = true
                
                result = sut.perform(input: input) { _ in
                    callbackExpectation.fulfill()
                }
            }
        }
        
        XCTAssertIdentical(viewController.toShowable(), result?.toShowable())
        XCTAssertNotNil(viewController.eventHandler)
        XCTAssertEqual(verificationService.getMobileNumberCallsCount, 1)
    }
    
    func test_perform_mobileNumberIsNotNil_doesNotCallGetMobileNumber_doesNotCallCallback() {
        let mobileNumber = "555555555"
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: mobileNumber)
        let expectedState = SignDocumentsState.mock(mobileNumber: mobileNumber)
        
        let sut = makeSut()
        
        var result: Showable?
        
        assertAsync { updateViewExpectation in
            viewController.updateViewCompletion = {
                XCTAssertEqual(self.viewController.updateViewArguments.last, expectedState)

                updateViewExpectation.fulfill()
            }
            
            assertAsync { callbackExpectation in
                callbackExpectation.isInverted = true
                
                result = sut.perform(input: input) { _ in
                    callbackExpectation.fulfill()
                }
            }
        }
        
        XCTAssertIdentical(viewController.toShowable(), result?.toShowable())
        XCTAssertNotNil(viewController.eventHandler)
        XCTAssertEqual(verificationService.getMobileNumberCallsCount, 0)
    }
    
    func test_perform_mobileNumberIsNil_callGetMobileNumberSucceeds_updatesStateWithExpectedValue() throws {
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedMobileNumber = "555555555"
        let expectedState = SignDocumentsState.mock(mobileNumber: expectedMobileNumber)
        
        let sut = makeSut()
        
        _ = sut.perform(input: input) { _ in }
        
        try assertAsync { updateViewExpectation in
            viewController.updateViewCompletion = {
                XCTAssertEqual(self.viewController.updateViewArguments.last, expectedState)
                
                updateViewExpectation.fulfill()
            }
            
            let getMobileNumberArgumentsCompletion = try XCTUnwrap(verificationService.getMobileNumberArguments.last)
            
            getMobileNumberArgumentsCompletion(.success(.init(id: nil, number: expectedMobileNumber, verified: true)))
        }
        
        XCTAssertEqual(verificationService.getMobileNumberCallsCount, 1)
    }
    
    func test_perform_mobileNumberIsNil_callGetMobileNumberFails_doesNotUpdateState() throws {
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedState = SignDocumentsState.mock()
        
        let sut = makeSut()

        _ = sut.perform(input: input) { _ in }

        try assertAsync { updateViewExpectation in
            updateViewExpectation.isInverted = true
            
            viewController.updateViewCompletion = {
                updateViewExpectation.fulfill()
            }
            
            let getMobileNumberArgumentsCompletion = try XCTUnwrap(verificationService.getMobileNumberArguments.last)
            
            getMobileNumberArgumentsCompletion(.failure(.init(.unknownError)))
        }
        
        XCTAssertEqual(verificationService.getMobileNumberCallsCount, 1)
        XCTAssertEqual(viewController.updateViewArguments.last, expectedState)
    }
    
    // MARK: - quit
    
    func test_quit_callsCallbackWithExpectedResult() {
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: nil)
        
        let sut = makeSut()
        
        assertAsync { expectation in
            _ = sut.perform(input: input) { result in
                XCTAssertResultIsSuccess(result) { value in
                    XCTAssertEqual(value, .quit)
                }
                
                expectation.fulfill()
            }
            
            viewController.eventHandler?.quit()
        }
    }
    
    // MARK: - requestNewCode
    
    func test_requestNewCode_callsSetupNewCodeTimer_callsAuthorizeDocuments() {
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: nil)
        let sut = makeSut()
        
        _ = sut.perform(input: input) { _ in }
        
        viewController.eventHandler?.requestNewCode()
        
        XCTAssertEqual(statusCheckService.setupNewCodeTimerCallsCount, 1)
        XCTAssertEqual(verificationService.authorizeDocumentsCallsCount, 1)
        XCTAssertEqual(verificationService.authorizeDocumentsArguments.last?.identificationUID, identificationUID)
    }
    
    func test_requestNewCode_setupNewCodeTimerCompletes_stateIsUpdated() throws {
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: nil)
        let sut = makeSut()
        let expectedNewCodeRemainingTime = 10
        let expectedState = SignDocumentsState.mock(newCodeRemainingTime: expectedNewCodeRemainingTime)
        
        _ = sut.perform(input: input) { _ in }
        
        viewController.eventHandler?.requestNewCode()
        
        assertAsync { expectation in
            viewController.updateViewCompletion = {
                expectation.fulfill()
            }
        }
        
        try assertAsync { expectation in
            viewController.updateViewCompletion = {
                XCTAssertEqual(self.viewController.updateViewArguments.last, expectedState)
                
                expectation.fulfill()
            }

            let setupNewCodeTimerCompletion = try XCTUnwrap(statusCheckService.setupNewCodeTimerArguments.last)
            
            setupNewCodeTimerCompletion(expectedNewCodeRemainingTime)
        }
    }
    
    func test_requestNewCode_authorizeDocumentsCompletesWithSuccessWithTransactionId_stateIsUpdated() throws {
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: nil)
        let sut = makeSut()
        let expectedTransactionId = "transaction_id"
        let expectedState = SignDocumentsState.mock(state: .codeAvailable, transactionId: expectedTransactionId)

        _ = sut.perform(input: input) { _ in }
        
        viewController.eventHandler?.requestNewCode()
        
        assertAsync { expectation in
            viewController.updateViewCompletion = {
                expectation.fulfill()
            }
        }
        
        try assertAsync { expectation in
            viewController.updateViewCompletion = {
                XCTAssertEqual(self.viewController.updateViewArguments.last, expectedState)
                
                expectation.fulfill()
            }

            let authorizeDocumentsCompletion = try XCTUnwrap(verificationService.authorizeDocumentsArguments.last?.completionHandler)
            
            authorizeDocumentsCompletion(.success(Identification.mock(referenceToken: expectedTransactionId)))
        }
    }
    
    func test_requestNewCode_authorizeDocumentsCompletesWithSuccessWithoutTransactionId_stateIsUpdated() throws {
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: nil)
        let sut = makeSut()
        let expectedState = SignDocumentsState.mock(state: .codeAvailable)
        
        _ = sut.perform(input: input) { _ in }
        
        viewController.eventHandler?.requestNewCode()
        
        assertAsync { expectation in
            viewController.updateViewCompletion = {
                expectation.fulfill()
            }
        }
        
        try assertAsync { expectation in
            viewController.updateViewCompletion = {
                XCTAssertEqual(self.viewController.updateViewArguments.last, expectedState)
                
                expectation.fulfill()
            }

            let authorizeDocumentsCompletion = try XCTUnwrap(verificationService.authorizeDocumentsArguments.last?.completionHandler)
            
            authorizeDocumentsCompletion(.success(Identification.mock(referenceToken: nil)))
        }
    }
    
    func test_requestNewCode_authorizeDocumentsCompletesWithFailure_stateIsUpdated_callsInvalidateNewCodeTimer() throws {
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: nil)
        let sut = makeSut()
        let expectedState = SignDocumentsState.mock(state: .codeUnavailable)
        
        _ = sut.perform(input: input) { _ in }
        
        viewController.eventHandler?.requestNewCode()
        
        assertAsync { expectation in
            viewController.updateViewCompletion = {
                expectation.fulfill()
            }
        }
        
        XCTAssertEqual(statusCheckService.invalidateNewCodeTimerCallsCount, 0)
        
        try assertAsync { expectation in
            viewController.updateViewCompletion = {
                XCTAssertEqual(self.viewController.updateViewArguments.last, expectedState)
                
                expectation.fulfill()
            }

            let authorizeDocumentsCompletion = try XCTUnwrap(verificationService.authorizeDocumentsArguments.last?.completionHandler)
            
            authorizeDocumentsCompletion(.failure(.init(.unknownError)))
        }
        
        XCTAssertEqual(statusCheckService.invalidateNewCodeTimerCallsCount, 1)
    }
    
    // MARK: - submitCodeAndSign
    
    func test_submitCodeAndSign_callsInvalidateNewCodeTimer_callsVerifyDocumentsTANWithExpectedArguments() {
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: nil)
        let sut = makeSut()
        
        _ = sut.perform(input: input) { _ in }
        
        viewController.eventHandler?.submitCodeAndSign(code)
        
        XCTAssertEqual(statusCheckService.invalidateNewCodeTimerCallsCount, 1)
        XCTAssertEqual(verificationService.verifyDocumentsTANCallsCount, 1)
        XCTAssertEqual(verificationService.verifyDocumentsTANArguments.last?.identificationUID, identificationUID)
        XCTAssertEqual(verificationService.verifyDocumentsTANArguments.last?.token, code)
    }
    
    func test_submitCodeAndSign_verifyDocumentsTANCompletesWithSuccess_statusConfirmed_updatesState_callsSetupStatusVerificationTimer() throws {
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: nil)
        let sut = makeSut()
        let expectedState = SignDocumentsState.mock(state: .processingIdentfication)
        
        _ = sut.perform(input: input) { _ in }
        
        viewController.eventHandler?.submitCodeAndSign(code)
        
        assertAsync { expectation in
            viewController.updateViewCompletion = {
                expectation.fulfill()
            }
        }
        
        try assertAsync { expectation in
            expectation.expectedFulfillmentCount = 2
            
            viewController.updateViewCompletion = {
                XCTAssertEqual(self.viewController.updateViewArguments.last, expectedState)
                
                expectation.fulfill()
            }
            
            statusCheckService.setupStatusVerificationTimerCompletion = {
                XCTAssertEqual(self.statusCheckService.setupStatusVerificationTimerArguments.last?.identificationUID, self.identificationUID)
                
                expectation.fulfill()
            }

            let verifyDocumentsTANCompletion = try XCTUnwrap(verificationService.verifyDocumentsTANArguments.last?.completionHandler)
            
            verifyDocumentsTANCompletion(.success(.mock(status: .confirmed)))
        }
    }
    
    func test_submitCodeAndSign_verifyDocumentsTANCompletesWithSuccess_statusConfirmed_setupStatusVerificationTimerCompletesWithConfirmed_updatesState_callsCallback() throws {
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: nil)
        let sut = makeSut()
        let expectedToken = "token"
        let expectedState = SignDocumentsState(state: .identificationSuccessful)
        
        try assertAsync { callbackExpectation in
            _ = sut.perform(input: input) { result in
                XCTAssertResultIsSuccess(result) { value in
                    XCTAssertEqual(value, .identificationConfirmed(token: expectedToken))
                }
                
                callbackExpectation.fulfill()
            }
            
            viewController.eventHandler?.submitCodeAndSign(code)
            
            try assertAsync { expectation in
                statusCheckService.setupStatusVerificationTimerCompletion = {
                    expectation.fulfill()
                }

                let verifyDocumentsTANCompletion = try XCTUnwrap(verificationService.verifyDocumentsTANArguments.last?.completionHandler)
                
                verifyDocumentsTANCompletion(.success(.mock(status: .confirmed)))
            }
            
            try assertAsync { expectation in
                viewController.updateViewCompletion = {
                    XCTAssertEqual(self.viewController.updateViewArguments.last, expectedState)
                    
                    expectation.fulfill()
                }
                
                let setupStatusVerificationTimerCallback = try XCTUnwrap(statusCheckService.setupStatusVerificationTimerArguments.last?.callback)
                
                setupStatusVerificationTimerCallback(.success(expectedToken))
            }
        }
    }
    
    func test_submitCodeAndSign_verifyDocumentsTANCompletesWithSuccess_statusConfirmed_setupStatusVerificationTimerCompletesWithSucceeded_updatesState_callsCallback() throws {
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: nil)
        let sut = makeSut()
        let expectedToken = "token"
        let expectedState = SignDocumentsState(state: .identificationSuccessful)

        try assertAsync(timeout: 0.3) { callbackExpectation in
            
            _ = sut.perform(input: input) { result in
                XCTAssertResultIsSuccess(result) { value in
                    XCTAssertEqual(value, .identificationConfirmed(token: expectedToken))
                }
                
                callbackExpectation.fulfill()
            }
            
            viewController.eventHandler?.submitCodeAndSign(code)
            
            try assertAsync { expectation in
                statusCheckService.setupStatusVerificationTimerCompletion = {
                    expectation.fulfill()
                }

                let verifyDocumentsTANCompletion = try XCTUnwrap(verificationService.verifyDocumentsTANArguments.last?.completionHandler)
                
                verifyDocumentsTANCompletion(.success(.mock(status: .confirmed)))
            }
            
            try assertAsync { expectation in
                viewController.updateViewCompletion = {
                    XCTAssertEqual(self.viewController.updateViewArguments.last, expectedState)
                    
                    expectation.fulfill()
                }
                
                let setupStatusVerificationTimerCallback = try XCTUnwrap(statusCheckService.setupStatusVerificationTimerArguments.last?.callback)
                
                setupStatusVerificationTimerCallback(.success(expectedToken))
            }
        }
    }
    
    func test_submitCodeAndSign_verifyDocumentsTANCompletesWithSuccess_statusConfirmed_setupStatusVerificationTimerCompletesWithFailure_doesNotUpdatesState_callsCallback() throws {
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: nil)
        let sut = makeSut()
        let expectedError = APIError.unknownError
        
        try assertAsync(timeout: 0.3) { callbackExpectation in
            _ = sut.perform(input: input) { result in
                XCTAssertResultIsFailure(result) { error in
                    XCTAssertEqual(error, expectedError)
                }
                
                callbackExpectation.fulfill()
            }
            
            viewController.eventHandler?.submitCodeAndSign(code)
            
            try assertAsync { expectation in
                statusCheckService.setupStatusVerificationTimerCompletion = {
                    expectation.fulfill()
                }

                let verifyDocumentsTANCompletion = try XCTUnwrap(verificationService.verifyDocumentsTANArguments.last?.completionHandler)
                
                verifyDocumentsTANCompletion(.success(.mock(status: .confirmed)))
            }
            
            try assertAsync { expectation in
                expectation.isInverted = true
                
                viewController.updateViewCompletion = {
                    expectation.fulfill()
                }
                
                let setupStatusVerificationTimerCallback = try XCTUnwrap(statusCheckService.setupStatusVerificationTimerArguments.last?.callback)
                
                setupStatusVerificationTimerCallback(.failure(expectedError))
            }
        }
    }
    
    
    func test_submitCodeAndSign_verifyDocumentsTANCompletesWithSuccess_statusOtherThanConfirmed_callsInvalidateNewCodeTimer_updatesState_doesNotCallCallback() throws {
        let statuses: [Status] = Status.allCases.filter { $0 != .confirmed }
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedState = SignDocumentsState.mock(state: .codeInvalid)

        try statuses.forEach { status in
            statusCheckService = StatusCheckServiceMock()
            viewController = UpdateableShowableMock()
            verificationService = VerificationServiceMock()
            
            let sut = makeSut()
            
            try assertAsync(timeout: 1.0) { callbackExpectation in
                callbackExpectation.isInverted = true
                _ = sut.perform(input: input) { _ in
                    callbackExpectation.fulfill()
                }
                
                viewController.eventHandler?.submitCodeAndSign(code)
                
                assertAsync { expectation in
                    viewController.updateViewCompletion = {
                        expectation.fulfill()
                    }
                }
                
                let invalidateNewCodeTimerCallsCount = statusCheckService.invalidateNewCodeTimerCallsCount
                
                try assertAsync(timeout: 0.3) { expectation in
                    expectation.expectedFulfillmentCount = 2
                    
                    statusCheckService.invalidateNewCodeTimerCompletion = {
                        expectation.fulfill()
                    }
                    
                    viewController.updateViewCompletion = {
                        XCTAssertEqual(self.viewController.updateViewArguments.last, expectedState)
                        
                        expectation.fulfill()
                    }

                    let verifyDocumentsTANCompletion = try XCTUnwrap(verificationService.verifyDocumentsTANArguments.last?.completionHandler)
                    
                    verifyDocumentsTANCompletion(.success(.mock(status: status)))
                }
                
                XCTAssertEqual(statusCheckService.invalidateNewCodeTimerCallsCount, invalidateNewCodeTimerCallsCount + 1)
            }
        }
    }
    
    func test_submitCodeAndSign_verifyDocumentsTANCompletesWithFailure_callsInvalidateNewCodeTimer_updatesState_doesNotCallCallback() throws {
        let input = SignDocumentsActionInput(identificationUID: identificationUID, mobileNumber: nil)
        let expectedState = SignDocumentsState.mock(state: .codeInvalid)

        let sut = makeSut()
        
        try assertAsync(timeout: 1.0) { callbackExpectation in
            callbackExpectation.isInverted = true
            _ = sut.perform(input: input) { _ in
                callbackExpectation.fulfill()
            }
            
            viewController.eventHandler?.submitCodeAndSign(code)
            
            assertAsync { expectation in
                viewController.updateViewCompletion = {
                    expectation.fulfill()
                }
            }
            
            let invalidateNewCodeTimerCallsCount = statusCheckService.invalidateNewCodeTimerCallsCount
            
            try assertAsync(timeout: 0.3) { expectation in
                expectation.expectedFulfillmentCount = 2
                
                statusCheckService.invalidateNewCodeTimerCompletion = {
                    expectation.fulfill()
                }
                
                viewController.updateViewCompletion = {
                    XCTAssertEqual(self.viewController.updateViewArguments.last, expectedState)
                    
                    expectation.fulfill()
                }
                
                let verifyDocumentsTANCompletion = try XCTUnwrap(verificationService.verifyDocumentsTANArguments.last?.completionHandler)
                
                verifyDocumentsTANCompletion(.failure(.init(.unknownError)))
            }
            
            XCTAssertEqual(statusCheckService.invalidateNewCodeTimerCallsCount, invalidateNewCodeTimerCallsCount + 1)
        }
    }
    
    private func makeSut() -> SignDocumentsAction<UpdateableShowableMock> {
        let sut = SignDocumentsAction(
            viewController: viewController,
            verificationService: verificationService,
            statusCheckService: statusCheckService
        )
        
        trackForMemoryLeaks(sut)
        
        return sut
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
