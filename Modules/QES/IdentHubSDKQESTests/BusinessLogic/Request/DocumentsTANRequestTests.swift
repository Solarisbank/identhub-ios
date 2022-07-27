//
//  DocumentsTANRequestTests.swift
//  IdentHubSDKQESTests
//

import XCTest
@testable import IdentHubSDKQES
import IdentHubSDKCore

final class DocumentsTANRequestTests: XCTestCase {

    let iduid = "c4bd19319a6f4b258c03687be2773a14avi"
    let token = "9536e7a3da5a00f15670ef5f459984e4cper"

    // MARK: - Tests methods -
    func testRequestPath() throws {
        let sut = try makeSUT(iduid, token)
        let expectedPath = String(describing: "/sign_documents/\(iduid)/confirm")

        XCTAssertEqual(sut.path, expectedPath, "Documents TAN request path is not valid")
    }

    func testRequestMethod() throws {
        let sut = try makeSUT(iduid, token)

        XCTAssertEqual(sut.method, .patch, "Documents TAN request HTTP methods is not correct, have to be PATCH")
    }

    func testRequestBodyIsNotNil() throws {
        let sut = try makeSUT(iduid, token)

        XCTAssertNotNil(sut.body?.httpBody, "Documents TAN request HTTP body data can't be nil")
    }

    func testEmptySessionToken() throws {
        let sut = try makeSUT(iduid, token)
        APIToken.sessionToken = ""
        
        XCTAssertThrowsError(try sut.asURLRequest(), "Documents TAN init method doesn't throws empty session token error", { err in
            XCTAssertEqual(err as! RequestError, .emptySessionToken, "Document TAN empty session token throws error .emptySessionToken")
        })
    }

    func testEmptyIUID() throws {
        XCTAssertThrowsError(try makeSUT("", token), "Documents TAN init method doesn't throws empty identificationUID error", { err in
            XCTAssertEqual(err as! RequestError, .emptyIUID, "Document TAN empty identification UID error is not correct, have to be .emptyIUID")
        })
    }

    func testEmptyToken() throws {
        XCTAssertThrowsError(try makeSUT(iduid, ""), "Documents TAN init method doesn't throws empty token error", { err in
            XCTAssertEqual(err as! RequestError, .emptyToken, "Document TAN empty token error is not correct, have to be .emptyToken")
        })
    }

    // MARK: - Internal methods -
    func makeSUT(_ iuid: String, _ token: String) throws -> DocumentsTANRequest {
        return try DocumentsTANRequest(identificationUID: iuid, token: token)
    }
}
