//
//  SBLogTest.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class SBLogTests: XCTestCase {

    func testLogLevelRepresentation() throws {
        XCTAssertEqual(SBLogLevel.debug.description, "DEBUG")
        XCTAssertEqual(SBLogLevel.info.description, "INFO")
        XCTAssertEqual(SBLogLevel.warn.description, "WARN")
        XCTAssertEqual(SBLogLevel.error.description, "ERROR")
        XCTAssertEqual(SBLogLevel.fault.description, "FAULT")
    }
    
    func testLogLevelOrder() throws {
        XCTAssert(SBLogLevel.debug < SBLogLevel.info)
        XCTAssert(SBLogLevel.info < SBLogLevel.warn)
        XCTAssert(SBLogLevel.warn < SBLogLevel.error)
        XCTAssert(SBLogLevel.error < SBLogLevel.fault)
    }

    func testLogMethods() throws {
        let log = SBLog()
        let message = "A log message"
        var entry: SBLogEntry
        
        entry = log.debug(message)
        XCTAssertEqual(entry.level, .debug)
        XCTAssertEqual(entry.message, message)

        entry = log.info(message)
        XCTAssertEqual(entry.level, .info)
        XCTAssertEqual(entry.message, message)

        entry = log.warn(message)
        XCTAssertEqual(entry.level, .warn)
        XCTAssertEqual(entry.message, message)

        entry = log.error(message)
        XCTAssertEqual(entry.level, .error)
        XCTAssertEqual(entry.message, message)
        
        entry = log.fault(message)
        XCTAssertEqual(entry.level, .fault)
        XCTAssertEqual(entry.message, message)

        entry = log.log(message, level: .error)
        XCTAssertEqual(entry.level, .error)
        XCTAssertEqual(entry.message, message)
    }
    
    func testLogCategoryRepresentation() throws {
        XCTAssertEqual(SBLogCategory.nav.description, "NAV")
        XCTAssertEqual(SBLogCategory.api.description, "API")
        XCTAssertEqual(SBLogCategory.other("TEST").description, "TEST")
    }
    
    func testLogCategories() throws {
        let log = SBLog()
        let message = "A log message"
        var entry: SBLogEntry
        
        entry = log.log(message, level: .debug)
        XCTAssertNil(entry.category)

        entry = log.log(message, level: .debug, category: .api)
        XCTAssertEqual(entry.category, .api)
        entry = log.log(message, level: .info, category: .nav)
        XCTAssertEqual(entry.category, .nav)
        
        let category = SBLogCategory.other("something")
        entry = log.log(message, level: .warn, category: category)
        XCTAssertEqual(entry.category, category)
    }
    
    func testLogTimestamp() throws {
        let timestampBefore = Date()
        let entry1 = SBLogEntry("A message", level: .debug)
        XCTAssertLessThanOrEqual(timestampBefore, entry1.timestamp)

        // We need to be sure we actually have a time difference
        let expectation = expectation(description: "delay to test timestamps")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let timestampAfter = Date()
            let entry2 = SBLogEntry("Another message", level: .info)
            XCTAssertLessThan(entry1.timestamp, timestampAfter)
            XCTAssertLessThanOrEqual(timestampAfter, entry2.timestamp)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
    }

    func testDestinationReceive() throws {
        let log = SBLog()
        let destinationMock = DestinationMock()
        log.addDestination(destinationMock)

        let expectation = keyValueObservingExpectation(for: destinationMock, keyPath: "sendCalledTimes", expectedValue: 1)
        
        let message = "A log message"
        let entry = log.debug(message)

        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(destinationMock.sendCalledTimes, 1)
        XCTAssertEqual(destinationMock.sendEntriesReceived.first, entry)
    }
    
    func testNoDuplicateDestinations() throws {
        let log = SBLog()
        let destinationMock1 = DestinationMock()
        log.addDestination(destinationMock1)
        log.addDestination(destinationMock1)
        XCTAssertEqual(log.destinationItems.count, 1)
        
        let destinationMock2 = DestinationMock()
        log.addDestination(destinationMock2)
        XCTAssertEqual(log.destinationItems.count, 2)
    }
    
    func testDestinationMultipleReceives() throws {
        let log = SBLog()
        let destinationMock = DestinationMock()
        log.addDestination(destinationMock)
        
        XCTAssertEqual(destinationMock.sendCalledTimes, 0)

        let expectation = keyValueObservingExpectation(for: destinationMock, keyPath: "sendCalledTimes", expectedValue: 3)

        let message = "A log message"
        let message2 = "Another log message"
        log.debug(message)
        log.debug(message)
        let entry = log.debug(message2)

        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(destinationMock.sendCalledTimes, 3)
        XCTAssertEqual(destinationMock.sendEntriesReceived.count, 3)
        XCTAssertEqual(destinationMock.sendEntriesReceived.last, entry)
    }
    
    func testCategoryLogger() throws {
        let log = SBLog()
        let navLog = SBCategorizingLog(.nav, log: log)
        
        // should set .nav category by default
        var entry = navLog.debug("A test message")
        XCTAssertEqual(entry.category, .nav)
        
        // should override explicit category
        entry = navLog.debug("A test message", category: .api)
        XCTAssertEqual(entry.category, .nav)
        
        // should log to the underlying logger
        let apiLog = log.withCategory(.api)
        XCTAssertEqual(apiLog.category, .api)
        let destinationMock = DestinationMock()
        log.addDestination(destinationMock)
        let expectation = keyValueObservingExpectation(for: destinationMock, keyPath: "sendCalledTimes", expectedValue: 1)
        apiLog.debug("A test message")
        wait(for: [expectation], timeout: 2)
    }

}

class DestinationMock: NSObject, SBLogDestination {
    var level: SBLogLevel = .debug
    
    @objc dynamic var sendCalledTimes = 0
    @objc dynamic var flushCalled = false
    var sendEntriesReceived = [SBLogEntry]()

    func send(_ entry: SBLogEntry) {
        self.sendEntriesReceived.append(entry)
        self.sendCalledTimes += 1
    }
    
    func flush() {
        self.flushCalled = true
    }
}
