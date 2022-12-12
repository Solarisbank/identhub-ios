//
//  PhoneVerificationEventHandlerTests.swift
//  IdentHubSDKCoreTests
//

@testable import IdentHubSDKCore
import XCTest
import IdentHubSDKTestBase

final class PhoneVerificationEventHandlerTests: XCTestCase {
    
    private var verificationService: VerificationServiceMock!
    private var storage: StorageMock!
    private let code = "012345"
    private let mobileNumber = "+0112345678"
    
    override func setUp() {
        super.setUp()
        verificationService = VerificationServiceMock()
        storage = StorageMock()
    }
    
    override func tearDown() {
        super.tearDown()
        verificationService = nil
        storage = nil
    }
    
    func test_perform_updatesViewWithExpectedState() {
        let input = PhoneVerificationInput()
        
        assertAsync { expectation in
            expectation.isInverted = true
            
            let showable = makeViewControllerWithSut(input: input) { _ in
                expectation.fulfill()
            }
            XCTAssertNotNil(showable.eventHandler)
        }
    }
    
    func test_quit_callsCallbackWithExpectedResult() {
        let input = PhoneVerificationInput()

        assertAsync { expectation in
            let showable = makeViewControllerWithSut(input: input) { result in
                XCTAssertResultIsSuccess(result) { value in
                    XCTAssertEqual(value, .abort)
                }
                expectation.fulfill()
            }
            showable.eventHandler?.handleEvent(.quit)
        }
    }
    
    private func makeViewControllerWithSut(input: PhoneVerificationInput, callback: @escaping (Result<PhoneVerificationOutput, APIError>) -> Void = { _ in }) -> UpdateableShowableMock {
        let showable = UpdateableShowableMock()
        makeSut(for: showable, input: input, callback: callback)
        return showable
    }
    
    
    private func makeSut(
        for showable: UpdateableShowableMock,
        input: PhoneVerificationInput,
        callback: @escaping (Result<PhoneVerificationOutput, APIError>) -> Void = { _ in XCTFail("Unexpected callback") }
    ) {
        let sut = PhoneVerificationEventHandlerImpl<UpdateableShowableMock>(
            verificationService: verificationService,
            input: input,
            storage: storage,
            callback: callback
        )
        showable.eventHandler = sut.asAnyEventHandler()
        sut.updateView = showable
        
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(showable)
    }
    
}

private extension PhoneVerificationState {
    static func mock(
        mobileNumber: String? = nil,
        state: PhoneVerificationState.State = .normal,
        seconds: Int = 0
    ) -> PhoneVerificationState {
        PhoneVerificationState(
            mobileNumber: mobileNumber,
            state: state,
            seconds: seconds
        )
    }
}

private class UpdateableShowableMock: UpdateableShowable {
    var eventHandler: AnyEventHandler<PhoneVerificationEvent>?

    var toShowableCallsCount = 0
    var toShowableReturnValue = UIViewController()
    
    var updateViewCallsCount = 0
    var updateViewArguments: [PhoneVerificationState] = []
    var updateViewCompletion: (() -> Void)?
    
    func toShowable() -> UIViewController {
        toShowableCallsCount += 1
        return toShowableReturnValue
    }
    
    func updateView(_ state: PhoneVerificationState) {
        updateViewCallsCount += 1
        updateViewArguments.append(state)
        updateViewCompletion?()
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
