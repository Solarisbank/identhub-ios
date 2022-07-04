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

        entry = log.log(level: .error, message: message)
        XCTAssertEqual(entry.level, .error)
        XCTAssertEqual(entry.message, message)
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
