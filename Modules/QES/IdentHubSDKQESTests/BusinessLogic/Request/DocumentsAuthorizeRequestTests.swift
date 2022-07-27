//
//  DocumentsAuthorizeRequestTests.swift
//  IdentHubSDKQESTests
//

import XCTest
@testable import IdentHubSDKQES
import IdentHubSDKCore

final class DocumentsAuthorizeRequestTests: XCTestCase {

    let iduid = "c4bd19319a6f4b258c03687be2773a14avi"

    // MARK: - Tests methods -
    func testRequestPath() throws {
        let sut = try makeSUT(iduid)
        let expectedPath = String(describing: "/sign_documents/\(iduid)/authorize")

        XCTAssertEqual(sut.path, expectedPath, "Documents authentication request path is not valid")
    }

    func testRequestMethod() throws {
        let sut = try makeSUT(iduid)

        XCTAssertEqual(sut.method, .patch, "Documents authentication request HTTP methods is not correct, have to be PATCH")
    }

    func testEmptySessionToken() throws {
        let sut = try makeSUT(iduid)
        APIToken.sessionToken = ""
        
        XCTAssertThrowsError(try sut.asURLRequest(), "Documents authentication init method doesn't throws empty session token error", { err in
            XCTAssertEqual(err as! RequestError, .emptySessionToken, "Document authentication empty session token throws error .emptySessionToken")
        })
    }

    func testEmptyIUID() throws {
        XCTAssertThrowsError(try makeSUT(""), "Documents authentication init method doesn't throws empty identificationUID error", { err in
            XCTAssertEqual(err as! RequestError, .emptyIUID, "Document authentication empty identification UID error is not correct, have to be .emptyIUID")
        })
    }

    // MARK: - Internal methods -
    func makeSUT(_ iuid: String) throws -> DocumentsAuthorizeRequest {
        return try DocumentsAuthorizeRequest(identificationUID: iuid)
    }
}
