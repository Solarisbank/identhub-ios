//
//  XCTestCase+TrackForMemoryLeaks.swift
//  IdentHubSDKTests
//

import XCTest

public extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTracking(instance)
    }
    
    
    func trackedForMemoryLeaks<Value: AnyObject>(_ instance: Value, file: StaticString = #filePath, line: UInt = #line) -> Value {
        addTracking(instance)
        
        return instance
    }
    
    private func addTracking<Value: AnyObject>(_ instance: Value, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential retain cycle.", file: file, line: line)
        }
    }
}
