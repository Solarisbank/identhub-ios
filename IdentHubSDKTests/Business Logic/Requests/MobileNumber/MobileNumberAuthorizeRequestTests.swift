//
//  MobileNumberAuthorizeRequestTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class MobileNumberAuthorizeRequestTests: XCTestCase {

    /// Test session id, used just for the tests execution
    var sessionId: String = "c4bd19319a6f4b258c03687be2773a14avi"

    // MARK: - Tests methods -

    func testRequestPath() throws {
        let sut = try makeSUT(sessionId)
        let expectedPath = String(describing: "/\(sessionId)/mobile_number/authorize")

        XCTAssertEqual(sut.path, expectedPath, "Mobile Number Authorization Request path built not correct")
    }

    func testRequestHTTPMethod() throws {
        let sut = try makeSUT(sessionId)

        XCTAssertEqual(sut.method, .post, "Request used wrong HTTP method, expected POST")
    }

    func testEmptySessionID() throws {
        XCTAssertThrowsError(try makeSUT(""), "Session ID have to be not empty") { error in
            XCTAssertEqual(error as! RequestError, RequestError.emptySessionID, "Error message have to be empty session id")
        }
    }

    // MARK: - Intermal methods -
    func makeSUT(_ id: String) throws -> MobileNumberAuthorizeRequest {
        return try MobileNumberAuthorizeRequest(sessionId: id)
    }
}
