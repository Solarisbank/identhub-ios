//
//  DocumentDownloadRequestTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK
import IdentHubSDKCore

class DocumentDownloadRequestTests: XCTestCase {

    let documentUID = "c4bd19319a6f4b258c03687be2773a14avi"

    // MARK: - Tests methods -
    func testRequestPath() throws {
        let sut = try makeSUT(documentUID)
        let expectedPath = String(describing: "/sign_documents/\(documentUID)/download")

        XCTAssertEqual(sut.path, expectedPath, "Document download request path is not valid")
    }

    func testRequestMethod() throws {
        let sut = try makeSUT(documentUID)

        XCTAssertEqual(sut.method, .get, "Document download request HTTP methods is not correct, have to be GET")
    }

    func testEmptySessionToken() throws {
        
        let sut = try makeSUT(documentUID)
        APIToken.sessionToken = ""
        
        XCTAssertThrowsError(try sut.asURLRequest(), "Document download init method doesn't throws empty session token error", { err in
            XCTAssertEqual(err as! RequestError, .emptySessionToken, "Document download empty session token throws error .emptySessionToken")
        })
    }

    func testEmptyDUID() throws {
        XCTAssertThrowsError(try makeSUT(""), "Document download init method doesn't throws empty documentUID error", { err in
            XCTAssertEqual(err as! RequestError, .emptyDUID, "Document download empty document UID error is not correct, have to be .emptyDUID")
        })
    }

    // MARK: - Internal methods -
    func makeSUT(_ duid: String) throws -> DocumentDownloadRequest {
        return try DocumentDownloadRequest(documentUID: duid)
    }
}
