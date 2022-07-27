//
//  MobileNumberTANRequestTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK
import IdentHubSDKCore

class MobileNumberTANRequestTests: XCTestCase {

    var token: String = "b79244907a97f325b83207443b29af84cpar;9536e7a3da5a00f15670ef5f459984e4cper;7cff7e6cf4e431c1fc99d15cc30b2652ises"

    // MARK: - Tests methods -
    func testRequestPath() throws {
        let sut = try makeSUT(token)
        let expectedPath = String(describing: "/mobile_number/confirm")

        XCTAssertEqual(sut.path, expectedPath, "Request path have to contain session ID")
    }

    func testRequestHTTPType() throws {
        let sut = try makeSUT(token)

        XCTAssertEqual(sut.method, .post, "Mobile number TAN verification request have to be with HTTP type POST")
    }

    func testRequestBody() throws {
        let sut = try makeSUT(token)

        XCTAssertNotNil(sut.body?.httpBody, "Mobile number TAN verification request have to have body")
    }

    func testEmptySessionIDError() throws {
        
        let sut = try makeSUT(token)
        APIToken.sessionToken = ""
        XCTAssertThrowsError(try sut.asURLRequest(), "Mobile number TAN verification request doesn't throws empty session token error", { err in
            XCTAssertEqual(err as! RequestError, .emptySessionToken, "Mobile number TAN verification empty session token throws error .emptySessionToken")
        })
    }

    func testEmptyTokenError() throws {
        XCTAssertThrowsError(try makeSUT(""), "Mobile number TAN verification request token should be not empty") { error in
            XCTAssertEqual(error as! RequestError, RequestError.emptyToken, "Request with empty token throws error: emptyToken")
        }
    }

    // MARK: - Internal methods -
    func makeSUT(_ token: String) throws -> MobileNumberTANRequest {
        return try MobileNumberTANRequest(token: token)
    }
}
