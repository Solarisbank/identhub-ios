//
//  XCTAssert.swift
//  IdentHubSDKTestBase
//

import XCTest

public func XCTAssertResultIsSuccess<T, U>(_ result: @autoclosure () throws -> Result<T, U>, evaluateValue: ((T) -> Void)? = nil, file: StaticString = #filePath, line: UInt = #line) {
    do {
        guard case .success(let value) = try result() else {
            XCTFail("result is not success", file: file, line: line)
            
            return
        }
        
        evaluateValue?(value)
    } catch {
        XCTFail(error.localizedDescription, file: file, line: line)
    }
}

public func XCTAssertResultIsFailure<T, U: Error>(_ result: @autoclosure () throws -> Result<T, U>, evaluateError: ((U) -> Void)? = nil, file: StaticString = #filePath, line: UInt = #line) {
    do {
        guard case .failure(let error) = try result() else {
            XCTFail("result is not failure", file: file, line: line)
            
            return
        }
        
        evaluateError?(error)
    } catch {
        XCTFail(error.localizedDescription, file: file, line: line)
    }
}

public func XCTAssertResultIsSuccess<T, U>(_ result: Result<T, U>, expectedValue: T, file: StaticString = #filePath, line: UInt = #line) where T: Equatable {
    XCTAssertResultIsSuccess(result) { XCTAssertEqual($0, expectedValue) }
}

public func XCTAssertResultIsSuccess<T, U>(_ result: Result<T, U>, expectedValue: T?, file: StaticString = #filePath, line: UInt = #line) where T: Equatable {
    XCTAssertResultIsSuccess(result) { XCTAssertEqual($0, expectedValue) }
}

public func XCTAssertResultIsFailure<T, U: Error & Equatable>(_ result: Result<T, U>, expectedError: U, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertResultIsFailure(result) { XCTAssertEqual($0, expectedError) }
}
