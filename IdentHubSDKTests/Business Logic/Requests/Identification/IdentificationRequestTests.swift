//
//  IdentificationRequestTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class IdentificationRequestTests: XCTestCase {

    /// Test session token, used just for the tests execution
    let sessionToken = "b79244907a97f325b83207443b29af84cpar;9536e7a3da5a00f15670ef5f459984e4cper;7cff7e6cf4e431c1fc99d15cc30b2652ises"
    let iduid = "c4bd19319a6f4b258c03687be2773a14avi"

    // MARK: - Tests methods -
    func testRequestPath() throws {
        let sut = try makeSUT(sessionToken, iduid)
        let expectedPath = String(describing: "/\(sessionToken)/identifications/\(iduid)")

        XCTAssertEqual(sut.path, expectedPath, "Documents authentication request path is not valid")
    }

    func testRequestMethod() throws {
        let sut = try makeSUT(sessionToken, iduid)

        XCTAssertEqual(sut.method, .get, "Documents authentication request HTTP methods is not correct, have to be GET")
    }

    func testEmptySessionToken() throws {
        XCTAssertThrowsError(try makeSUT("", iduid), "Documents authentication init method doesn't throws empty session token error", { err in
            XCTAssertEqual(err as! RequestError, .emptySessionToken, "Document authentication empty session token error is not correct, have to be .emptySessionToken")
        })
    }

    func testEmptyIUID() throws {
        XCTAssertThrowsError(try makeSUT(sessionToken, ""), "Documents authentication init method doesn't throws empty identificationUID error", { err in
            XCTAssertEqual(err as! RequestError, .emptyIUID, "Document authentication empty identification UID error is not correct, have to be .emptyIUID")
        })
    }

    // MARK: - Internal methods -
    func makeSUT(_ sessionToken: String, _ iuid: String) throws -> IdentificationRequest {
        return try IdentificationRequest(sessionToken: sessionToken, identificationUID: iuid)
    }
}
