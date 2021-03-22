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

        sut.clear()

        XCTAssertTrue(sut.sessionToken.isEmpty, "Storage session provider data wasn't cleared properly")
        XCTAssertNil(sut.mobileNumber, "Mobile number value in storage session provider wasn't cleared")
    }

    // MARK: - Internal methods -
    func makeSUT() -> StorageSessionInfoProvider {
        return StorageSessionInfoProvider(sessionToken: token)
    }
}
