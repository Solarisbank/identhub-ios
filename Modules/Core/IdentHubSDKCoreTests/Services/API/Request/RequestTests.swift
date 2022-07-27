//
//  RequestTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDKCore

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
    
    func testEmptySessionToken() {
        let sut = RequestMOCK()
        APIToken.sessionToken = ""
        XCTAssertThrowsError(try sut.asURLRequest(), "Making url request method doesn't throws empty session token error", { err in
            XCTAssertEqual(err as! RequestError, .emptySessionToken, "Request with empty session token throws error .emptySessionToken")
        })
    }
}

final class RequestMOCK: Request {
    var path: String = ""

    var method: HTTPMethod = .get
}
