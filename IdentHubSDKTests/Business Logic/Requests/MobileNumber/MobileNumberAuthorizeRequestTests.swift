//
//  MobileNumberAuthorizeRequestTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK
import IdentHubSDKCore

class MobileNumberAuthorizeRequestTests: XCTestCase {

    /// Test session id, used just for the tests execution
    var sessionId: String = "c4bd19319a6f4b258c03687be2773a14avi"

    // MARK: - Tests methods -

    func testRequestPath() throws {
        let sut = makeSUT()
        let expectedPath = String(describing: "/mobile_number/authorize")

        XCTAssertEqual(sut.path, expectedPath, "Mobile Number Authorization Request path built not correct")
    }

    func testRequestHTTPMethod() throws {
        let sut = makeSUT()

        XCTAssertEqual(sut.method, .post, "Request used wrong HTTP method, expected POST")
    }

    func testEmptySessionID() throws {
        let sut = makeSUT()
        APIToken.sessionToken = ""
        
        XCTAssertThrowsError(try sut.asURLRequest(), "Mobile NumberAuthorize init method doesn't throws empty session token error", { err in
            XCTAssertEqual(err as! RequestError, .emptySessionToken, "Mobile NumberAuthorize empty session token throws error .emptySessionToken")
        })
    }

    // MARK: - Intermal methods -
    func makeSUT() -> MobileNumberAuthorizeRequest {
        return MobileNumberAuthorizeRequest()
    }
}
