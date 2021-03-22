//
//  DocumentDownloadRequestTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class DocumentDownloadRequestTests: XCTestCase {

    /// Test session token, used just for the tests execution
    let sessionToken = "b79244907a97f325b83207443b29af84cpar;9536e7a3da5a00f15670ef5f459984e4cper;7cff7e6cf4e431c1fc99d15cc30b2652ises"
    let documentUID = "c4bd19319a6f4b258c03687be2773a14avi"

    // MARK: - Tests methods -
    func testRequestPath() throws {
        let sut = try makeSUT(sessionToken, documentUID)
        let expectedPath = String(describing: "/\(sessionToken)/sign_documents/\(documentUID)/download")

        XCTAssertEqual(sut.path, expectedPath, "Document download request path is not valid")
    }

    func testRequestMethod() throws {
        let sut = try makeSUT(sessionToken, documentUID)

        XCTAssertEqual(sut.method, .get, "Document download request HTTP methods is not correct, have to be GET")
    }

    func testEmptySessionToken() throws {
        XCTAssertThrowsError(try makeSUT("", documentUID), "Document download init method doesn't throws empty session token error", { err in
            XCTAssertEqual(err as! RequestError, .emptySessionToken, "Document download empty session token error is not correct, have to be .emptySessionToken")
        })
    }

    func testEmptyDUID() throws {
        XCTAssertThrowsError(try makeSUT(sessionToken, ""), "Document download init method doesn't throws empty documentUID error", { err in
            XCTAssertEqual(err as! RequestError, .emptyDUID, "Document download empty document UID error is not correct, have to be .emptyDUID")
        })
    }

    // MARK: - Internal methods -
    func makeSUT(_ sessionToken: String, _ duid: String) throws -> DocumentDownloadRequest {
        return try DocumentDownloadRequest(sessionToken: sessionToken, documentUID: duid)
    }
}
