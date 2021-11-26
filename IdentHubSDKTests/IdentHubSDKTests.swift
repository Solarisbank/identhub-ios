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

    func test_empty() {
        XCTExpectFailure("Ident Hub SDK service partially covered with tests. Delete empty method when it would be covered.")
        XCTFail("Iden hub sdk does not covered with tests")
    }

    // MARK: - Internal methods methods -
    func makeManager() throws -> IdentHubSession {
        let rootVC = UIViewController()

        return try IdentHubSession(rootViewController: rootVC, sessionURL: sessionURL)
    }
}
