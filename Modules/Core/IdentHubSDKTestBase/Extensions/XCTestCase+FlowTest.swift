//
//  XCTestCase+FlowTest.swift
//  IdentHubSDKTestBase
//

import XCTest

public protocol FlowTest {
    associatedtype Input
    associatedtype Output: Equatable
    associatedtype ViewState
    associatedtype EventHandler
    
    func makeShowableWithSut(input: Input, callback: @escaping (Output) -> Void) -> UpdateableMock<ViewState, EventHandler>
}

public extension FlowTest where Self: XCTestCase {
    
    func assertFlow(
        input: Input,
        expectedOutput: Output? = nil,
        checks: (UpdateableMock<ViewState, EventHandler>) -> Void
    ) {
        let expectation = expectation(description: name)

        if expectedOutput == nil {
            expectation.isInverted = true
        }

        let showable = makeShowableWithSut(input: input) { result in
            if let expectedOutput = expectedOutput {
                XCTAssertEqual(result, expectedOutput)
                expectation.fulfill()
            } else {
                XCTFail("Unexpected callback with result \(result)")
            }
        }
        checks(showable)

        wait(for: [expectation], timeout: 0.1)

        assertOnMainThread {}
    }
}
