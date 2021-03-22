//
//  DocumentsTANRequestTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class DocumentsTANRequestTests: XCTestCase {

    /// Test session token, used just for the tests execution
    let sessionToken = "b79244907a97f325b83207443b29af84cpar;9536e7a3da5a00f15670ef5f459984e4cper;7cff7e6cf4e431c1fc99d15cc30b2652ises"
    let iduid = "c4bd19319a6f4b258c03687be2773a14avi"
    let token = "9536e7a3da5a00f15670ef5f459984e4cper"

    // MARK: - Tests methods -
    func testRequestPath() throws {
        let sut = try makeSUT(sessionToken, iduid, token)
        let expectedPath = String(describing: "/\(sessionToken)/sign_documents/\(iduid)/confirm")

        XCTAssertEqual(sut.path, expectedPath, "Documents TAN request path is not valid")
    }

    func testRequestMethod() throws {
        let sut = try makeSUT(sessionToken, iduid, token)

        XCTAssertEqual(sut.method, .patch, "Documents TAN request HTTP methods is not correct, have to be PATCH")
    }

    func testRequestBodyIsNotNil() throws {
        let sut = try makeSUT(sessionToken, iduid, token)

        XCTAssertNotNil(sut.body?.httpBody, "Documents TAN request HTTP body data can't be nil")
    }

    func testEmptySessionToken() throws {
        XCTAssertThrowsError(try makeSUT("", iduid, token), "Documents TAN init method doesn't throws empty session token error", { err in
            XCTAssertEqual(err as! RequestError, .emptySessionToken, "Document TAN empty session token error is not correct, have to be .emptySessionToken")
        })
    }

    func testEmptyIUID() throws {
        XCTAssertThrowsError(try makeSUT(sessionToken, "", token), "Documents TAN init method doesn't throws empty identificationUID error", { err in
            XCTAssertEqual(err as! RequestError, .emptyIUID, "Document TAN empty identification UID error is not correct, have to be .emptyIUID")
        })
    }

    func testEmptyToken() throws {
        XCTAssertThrowsError(try makeSUT(sessionToken, iduid, ""), "Documents TAN init method doesn't throws empty token error", { err in
            XCTAssertEqual(err as! RequestError, .emptyToken, "Document TAN empty token error is not correct, have to be .emptyToken")
        })
    }

    // MARK: - Internal methods -
    func makeSUT(_ sessionToken: String, _ iuid: String, _ token: String) throws -> DocumentsTANRequest {
        return try DocumentsTANRequest(sessionToken: sessionToken, identificationUID: iuid, token: token)
    }
}
