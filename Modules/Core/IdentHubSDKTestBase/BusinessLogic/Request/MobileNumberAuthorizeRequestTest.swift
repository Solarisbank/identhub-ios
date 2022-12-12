//
//  MobileNumberAuthorizeRequestTest.swift
//  IdentHubSDKCoreTests
//

import XCTest
@testable import IdentHubSDKCore

final class MobileNumberAuthorizeRequestTest: XCTestCase {

    // MARK: - Tests methods -

    func testRequestPath() throws {
        let sut = makeSUT()
        let expectedPath = String(describing: "/mobile_number/authorize")

        XCTAssertEqual(sut.path, expectedPath, "Mobile Number Authorize Request path built not correct")
    }

    func testRequestHTTPMethod() throws {
        let sut = makeSUT()
        XCTAssertEqual(sut.method, .post, "Request used wrong HTTP method, expected Post")
    }

    func testEmptySessionID() throws {
        let sut = makeSUT()
        APIToken.sessionToken = ""
        
        XCTAssertThrowsError(try sut.asURLRequest(), "Mobile Number Authorize init method doesn't throws empty session token error", { err in
            XCTAssertEqual(err as! RequestError, .emptySessionToken, "Mobile Number Authorize empty session token throws error .emptySessionToken")
        })
    }

    // MARK: - Internal methods -
    
    func makeSUT() -> MobileNumberAuthorizeRequest {
        return MobileNumberAuthorizeRequest()
    }
}
