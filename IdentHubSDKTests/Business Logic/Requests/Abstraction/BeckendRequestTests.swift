//
//  BeckendRequestTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class BeckendRequestTests: XCTestCase {

    // MARK: - Test methods -

    /// Method tested default server url
    func testBasePath() {
        let sut = BackendRequestMock()
        let expectedPath = "https://person-onboarding-api.solaris-testing.de"

        XCTAssertEqual(sut.basePath, expectedPath, "Base url path in Request protocol changed")
    }

    /// Method tested default API path
    func testAPIPath() {
        let sut = BackendRequestMock()
        let expectedPath = "/person_onboarding"

        XCTAssertEqual(sut.apiPath, expectedPath, "API url path in Request protocol changed")
    }
}

final class BackendRequestMock: BackendRequest {
    var path: String = ""

    var method: HTTPMethod = .get
}
