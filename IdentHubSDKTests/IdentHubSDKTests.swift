//
//  IdentHubSDKTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class IdentHubSDKTests: XCTestCase {

    /// Tested session token
    let sessionURL = "http://localhost/79244907a97f325b83207443b29af84cpar23j4kjerihfijaerj32i8iejfoij8h8jadfij3298y"

    // MARK: - Tests methods -

    /// Tested start SDK manager method execution
    /// Session active if manager executed start bankid type identification process
    func testBankIDActiveSession() throws {
        let sut = try makeManager()

        sut.start(.bankID, completion: { _ in })

        XCTAssertTrue(sut.bankIDSessionActiveState, "Session wasn't started in ident hub manager")
    }

    /// Tested start SDK manager method execution
    /// Session active if manager executed start fourthline type identification process
    func testFourthlineActiveSession() throws {
        let sut = try makeManager()

        sut.start(.fouthline, completion: { _ in })

        XCTAssertTrue(sut.fourthlineSessionActiveState, "Session wasn't started in ident hub manager")
    }

    /// Tested SDK manager inactive state
    /// Session is not if manager never executed start command
    func testInactiveSession() throws {
        let sut = try makeManager()

        XCTAssertFalse(sut.bankIDSessionActiveState, "Bank identification session shouldn't start automatically")
        XCTAssertFalse(sut.fourthlineSessionActiveState, "Fourthline identification session shoudn't start automatically")
    }

    // MARK: - Internal methods methods -
    func makeManager() throws -> IdentHubSession {
        let rootVC = UIViewController()

        return try IdentHubSession(rootViewController: rootVC, sessionURL: sessionURL)
    }
}