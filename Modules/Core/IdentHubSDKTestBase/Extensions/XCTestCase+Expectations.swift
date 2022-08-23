//
//  XCTestCase+Testing.swift
//  IdentHubSDKTestBase
//
import XCTest
import IdentHubSDKCore

public extension XCTestCase {
    static let defaultTimeout = 0.1
    static let defaultActionTimeout = 10.0
    static let defaultViewInStateTimeout = 10.0

    func assertOnMainThread(checks: @escaping () -> Void) {
        assertAsync { expectation in
            DispatchQueue.main.async {
                checks()
                expectation.fulfill()
            }
        }
    }

    func assertAsync(timeout: TimeInterval = defaultTimeout, checks: (XCTestExpectation) -> Void) {
        let expectation = expectation(description: name)
        checks(expectation)
        wait(for: [expectation], timeout: timeout)
    }
    
    func assertAsync(timeout: TimeInterval = defaultTimeout, checks: (XCTestExpectation) throws -> Void) throws {
        let expectation = expectation(description: name)
        try checks(expectation)
        wait(for: [expectation], timeout: timeout)
    }

    func assertAsyncCoordinatorStart<C: FlowCoordinator>(
        _ coordinator: C,
        with input: C.Input,
        name: String = #function,
        expectedResult: Result<C.Output, C.Failure>,
        timeout: TimeInterval = defaultActionTimeout,
        checks: () -> Void
    ) where C.Output: Equatable, C.Failure: Equatable {

        let expectation = expectation(description: name)
        _ = coordinator.start(input: input) { result in
            XCTAssertEqual(result, expectedResult)
            expectation.fulfill()
        }
        checks()
        wait(for: [expectation], timeout: timeout)
    }
    
    func assertAsyncViewStateIn<ViewState, EventHandler>(
        _ updateable: UpdateableMock<ViewState, EventHandler>,
        timeout: TimeInterval = defaultViewInStateTimeout,
        expectedState: @escaping (ViewState) -> Bool = { _ in return true }
    ) {
        let expectation = updateable.expect(in: self, state: expectedState)
        wait(for: [expectation], timeout: timeout)
    }
}
