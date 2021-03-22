//
//  IBANTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class IBANRequestTests: XCTestCase {

    /// Test session token, used just for the tests execution
    var sessionToken = "b79244907a97f325b83207443b29af84cpar;9536e7a3da5a00f15670ef5f459984e4cper;7cff7e6cf4e431c1fc99d15cc30b2652ises"
    var iban = "DE11231231231231"

    // MARK: - Tests methods -
    func testRequestPath() throws {
        let sut = try makeSUT(sessionToken, iban)
        let expectedPath = String(describing: "/\(sessionToken)/iban/verify")

        XCTAssertEqual(sut.path, expectedPath, "Error with correct request path, iban value is not valid")
    }

    func testRequestHTTPMethod() throws {
        let sut = try makeSUT(sessionToken, iban)

        XCTAssertEqual(sut.method, .post, "Wrong IBAN request HTTP method, have to be POST")
    }

    func testRequestBody() throws {
        let sut = try makeSUT(sessionToken, iban)

        XCTAssertNotNil(sut.body?.httpBody, "Error with IBAN request HTTP body, body is nil")
    }

    func testRequestEmptySessionToken() throws {
        XCTAssertThrowsError(try makeSUT("", iban), "Init method of IBAN doesn't handle properly empty session token value") { error in
            XCTAssertEqual(error as! RequestError, .emptySessionToken, "IBAN request empty session tocken error is not correct, should be .emptySessionToken")
        }
    }

    func testRequestEmptyIBAN() throws {
        XCTAssertThrowsError(try makeSUT(sessionToken, ""), "Init method of IBAN request doens't handled properly empty value of the IBAN string") { error in
            XCTAssertEqual(error as! RequestError, .emptyIBAN, "IBAN request empty iban string value error is not correct, have to be .emptyIBAN")
        }
    }

    // MARK: - Internal methods -
    func makeSUT(_ sessionToken: String, _ iban: String) throws -> IBANRequest {
        return try IBANRequest(sessionToken: sessionToken, iban: iban)
    }
}
