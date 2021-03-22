//
//  RequestTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class RequestTests: XCTestCase {

    // MARK: - Test methods -

    /// Method tested default server url
    func testBasePath() {
        let sut = RequestMOCK()
        let expectedPath = "https://api.solaris-testing.de"

        XCTAssertEqual(sut.basePath, expectedPath, "Base url path in Request protocol changed")
    }

    /// Method tested default API path
    func testAPIPath() {
        let sut = RequestMOCK()
        let expectedPath = "/v1/person_onboarding"

        XCTAssertEqual(sut.apiPath, expectedPath, "API url path in Request protocol changed")
    }
}

final class RequestMOCK: Request {
    var path: String = ""

    var method: HTTPMethod = .get
}
