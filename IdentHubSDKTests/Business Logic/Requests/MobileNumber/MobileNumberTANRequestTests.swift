//
//  MobileNumberTANRequestTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class MobileNumberTANRequestTests: XCTestCase {

    /// Test session id and token, used just for the tests execution
    var sessionId: String = "c4bd19319a6f4b258c03687be2773a14avi"
    var token: String = "b79244907a97f325b83207443b29af84cpar;9536e7a3da5a00f15670ef5f459984e4cper;7cff7e6cf4e431c1fc99d15cc30b2652ises"

    // MARK: - Tests methods -
    func testRequestPath() throws {
        let sut = try makeSUT(sessionId, token)
        let expectedPath = String(describing: "/\(sessionId)/mobile_number/confirm")

        XCTAssertEqual(sut.path, expectedPath, "Request path have to contain session ID")
    }

    func testRequestHTTPType() throws {
        let sut = try makeSUT(sessionId, token)

        XCTAssertEqual(sut.method, .post, "Mobile number TAN verification request have to be with HTTP type POST")
    }

    func testRequestBody() throws {
        let sut = try makeSUT(sessionId, token)

        XCTAssertNotNil(sut.body?.httpBody, "Mobile number TAN verification request have to have body")
    }

    func testEmptySessionIDError() throws {
        XCTAssertThrowsError(try makeSUT("", token), "Mobile number TAN verification request session ID should be not empty") { error in
            XCTAssertEqual(error as! RequestError, RequestError.emptySessionID, "Request with empty session ID throws error: emptySessionID")
        }
    }

    func testEmptyTokenError() throws {
        XCTAssertThrowsError(try makeSUT(sessionId, ""), "Mobile number TAN verification request token should be not empty") { error in
            XCTAssertEqual(error as! RequestError, RequestError.emptyToken, "Request with empty token throws error: emptyToken")
        }
    }

    // MARK: - Internal methods -
    func makeSUT(_ sessionID: String, _ token: String) throws -> MobileNumberTANRequest {
        return try MobileNumberTANRequest(sessionId: sessionID, token: token)
    }
}
