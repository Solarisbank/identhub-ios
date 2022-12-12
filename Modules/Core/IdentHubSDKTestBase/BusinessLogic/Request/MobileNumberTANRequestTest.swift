//
//  MobileNumberTANRequestTest.swift
//  IdentHubSDKCoreTests
//

import XCTest
@testable import IdentHubSDKCore

final class MobileNumberTANRequestTest: XCTestCase {
    
    let token = "012345"

    // MARK: - Tests methods -

    func testRequestPath() throws {
        let sut = try makeSUT(token)
        let expectedPath = String(describing: "/mobile_number/confirm")

        XCTAssertEqual(sut.path, expectedPath, "Mobile Number TAN Request path built not correct")
    }

    func testRequestHTTPMethod() throws {
        let sut = try makeSUT(token)
        XCTAssertEqual(sut.method, .post, "Request used wrong HTTP method, expected Post")
    }
    
    func testRequestBodyIsNotNil() throws {
        let sut = try makeSUT(token)
        XCTAssertNotNil(sut.body?.httpBody, "Mobile Number TAN request HTTP body data can't be nil")
    }

    func testEmptySessionID() throws {
        let sut = try makeSUT(token)
        APIToken.sessionToken = ""
        
        XCTAssertThrowsError(try sut.asURLRequest(), "Mobile Number TAN init method doesn't throws empty session token error", { err in
            XCTAssertEqual(err as! RequestError, .emptySessionToken, "Mobile Number TAN empty session token throws error .emptySessionToken")
        })
    }
    
    func testEmptyToken() throws {
        XCTAssertThrowsError(try makeSUT(""), "Mobile Number TAN init method doesn't throws empty token error", { err in
            XCTAssertEqual(err as! RequestError, .emptyToken, "Document TAN empty token error is not correct, have to be .emptyToken")
        })
    }

    // MARK: - Internal methods -
    
    func makeSUT(_ token: String) throws -> MobileNumberTANRequest {
        return try MobileNumberTANRequest(token: token)
    }

}
