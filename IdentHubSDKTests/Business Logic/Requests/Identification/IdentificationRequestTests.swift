//
//  IdentificationRequestTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK
import IdentHubSDKCore

class IdentificationRequestTests: XCTestCase {

    let iduid = "c4bd19319a6f4b258c03687be2773a14avi"

    // MARK: - Tests methods -
    func testRequestPath() throws {
        let sut = try makeSUT(iduid)
        let expectedPath = String(describing: "/identifications/\(iduid)")

        XCTAssertEqual(sut.path, expectedPath, "Documents authentication request path is not valid")
    }

    func testRequestMethod() throws {
        let sut = try makeSUT(iduid)

        XCTAssertEqual(sut.method, .get, "Documents authentication request HTTP methods is not correct, have to be GET")
    }

    func testEmptySessionToken() throws {
        let sut = try makeSUT(iduid)
        APIToken.sessionToken = ""
        
        XCTAssertThrowsError(try sut.asURLRequest(), "Documents authentication doesn't throws empty session token error", { err in
            XCTAssertEqual(err as! RequestError, .emptySessionToken, "Document authentication empty session token throws error .emptySessionToken")
        })
    }

    func testEmptyIUID() throws {
        XCTAssertThrowsError(try makeSUT(""), "Documents authentication init method doesn't throws empty identificationUID error", { err in
            XCTAssertEqual(err as! RequestError, .emptyIUID, "Document authentication empty identification UID error is not correct, have to be .emptyIUID")
        })
    }

    // MARK: - Internal methods -
    func makeSUT(_ iuid: String) throws -> IdentificationRequest {
        return try IdentificationRequest(identificationUID: iuid)
    }
}
