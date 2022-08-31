//
//  UpdateableMock.swift
//  IdentHubSDKTestBase
//
import IdentHubSDKCore
import UIKit
import XCTest
import IdentHubSDKQES

public class UpdateableMock<ViewState, Event>: Updateable {
    public var state: ViewState!
    public var eventHandler: AnyEventHandler<Event>?
    public var recorder: TestRecorder?
    private var stateExpectation: XCTestExpectation?
    private var stateExpectationCheck: ((ViewState) -> Bool)?

    public init(recorder: TestRecorder? = nil) {
        self.recorder = recorder
    }
    
    public func checkState(_ check: @escaping (ViewState) -> Void) {
        check(self.state)
    }

    public func updateView(_ state: ViewState) {
        self.state = state
        recorder?.record(event: .updateView, value: state)
    }
    
    public func sendEvent(_ event: Event) {
        self.recorder?.record(event: .event, value: event)
        self.eventHandler?.handleEvent(event)
    }

    @discardableResult
    public func expect(in test: XCTestCase, state checkState: @escaping (ViewState) -> Bool) -> XCTestExpectation {
        stateExpectation = XCTestExpectation(description: "Wait for view state")
        stateExpectationCheck = checkState
        
        let predicate = NSPredicate { [weak self] _, _ in
            guard let self = self else {
                return false
            }
            return checkState(self.state)
        }
        let expectation = test.expectation(for: predicate, evaluatedWith: self)
        if predicate.evaluate(with: self) {
            expectation.fulfill()
        }
        return expectation
    }
    
}

extension UpdateableMock: Showable {
    public func toShowable() -> UIViewController {
        UIViewController()
    }
}
