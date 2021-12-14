//
//  AsyncTestCases.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class BaseTestCase: XCTestCase {

    /// Method clears data from the session storage
    /// used before launching every single test to make sure data from another test is not populated in UserDefaults and can't corrupt expected test results
    func resetStorage() {
        SessionStorage.clearData()
    }
    
    /// Method executes test code block in main thread asynchronosly with 1 second expectation time out
    /// if code was not executed during 1 second test marks as failed
    /// - Parameter completion: test execution block
    func executeAsyncTest(_ execution: @escaping () throws -> Void) {
        let asyncExpectation = XCTestExpectation(description: "Code executes in main thread with 1 second expectation")
        
        DispatchQueue.main.async {
            try! execution()
            asyncExpectation.fulfill()
        }
        
        wait(for: [asyncExpectation], timeout: 1.0)
    }
}
