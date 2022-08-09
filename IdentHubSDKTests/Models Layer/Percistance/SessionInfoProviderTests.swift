//
//  SessionInfoProviderTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class SessionInfoProviderTests: XCTestCase {

    var token: String = "b79244907a97f325b83207443b29af84cpar;9536e7a3da5a00f15670ef5f459984e4cper;7cff7e6cf4e431c1fc99d15cc30b2652ises"

    // MARK: - Tests methods -
    func testSessionToken() {
        let sut = makeSUT()

        XCTAssertEqual(sut.sessionToken, token, "Storage session provider token mismatch")
    }

    func clearProviderData() {
        let sut = makeSUT()
        let testMobileNumber = "+380(12) 123-45-56"

        sut.mobileNumber = testMobileNumber

        XCTAssertEqual(sut.mobileNumber, testMobileNumber, "Mobile number in storage session provider mismatch with assigned value")

        XCTAssertTrue(sut.sessionToken.isEmpty, "Storage session provider data wasn't cleared properly")
        XCTAssertNil(sut.mobileNumber, "Mobile number value in storage session provider wasn't cleared")
    }
    
    func test_addEnableRemoteLoggingCallback_remoteLoggingIsEnabled_callsCalbackImmediatelyWithValue() {
        let sut = makeSUT()
        
        sut.remoteLogging = true
        
        assertAsync { expectation in
            sut.addEnableRemoteLoggingCallback {
                expectation.fulfill()
            }
        }
    }
    
    func test_addEnableRemoteLoggingCallback_remoteLoggingIsDisabled_doesNotCallCallback() {
        let sut = makeSUT()
        
        sut.remoteLogging = false
        
        assertAsync { expectation in
            expectation.isInverted = true
            
            sut.addEnableRemoteLoggingCallback {
                expectation.fulfill()
            }
        }
    }
    
    func test_addEnableRemoteLoggingCallback_remoteLoggingIsDisabledAndThenEnabled_callsCallbackExpectedTimes() {
        let sut = makeSUT()

        assertAsync { expectation in
            expectation.expectedFulfillmentCount = 2
            
            sut.addEnableRemoteLoggingCallback {
                expectation.fulfill()
            }
            
            sut.remoteLogging = false
            sut.remoteLogging = true
            sut.remoteLogging = true
            sut.remoteLogging = false
            sut.remoteLogging = true
        }
    }

    // MARK: - Internal methods -
    func makeSUT() -> StorageSessionInfoProvider {
        return StorageSessionInfoProvider(sessionToken: token)
    }
}
