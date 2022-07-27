//
//  ActionMock.swift
//  IdentHubSDKTestBase
//
import IdentHubSDKCore
import XCTest

public class ActionMock<Input, ActionResult>: Action {
    private var callback: ((ActionResult) -> Void)!
    private var testRecorder: TestRecorder?
    private var name: String
    private var resultMock: (result: ActionResult, isFinished: Bool)?

    public init(name: String, testRecorder: TestRecorder? = nil) {
        self.name = name
        self.testRecorder = testRecorder
    }

    public func perform(input: Input, callback: @escaping (ActionResult) -> Void) -> Showable? {
        XCTAssertNil(self.callback)

        testRecorder?.record(event: .action, value: "\(name).perform(\(input))")

        self.callback = callback

        if let result = resultMock {
            DispatchQueue.main.async {
                self.performCallback(result: result)
            }
        }
        return nil
    }
    
    public func mockCallback(with result: ActionResult, isFinished: Bool = false) {
        performCallback(result: (result: result, isFinished: isFinished))
    }
    
    private func performCallback(result: (result: ActionResult, isFinished: Bool)) {
        testRecorder?.record(event: .action, value: "\(name).callback(\(result))")
        callback(result.result)
        if result.isFinished {
            self.callback = nil
        }
    }
}
