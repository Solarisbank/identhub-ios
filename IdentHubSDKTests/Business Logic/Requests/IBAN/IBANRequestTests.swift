//
//  IBANTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class IBANRequestTests: XCTestCase {

    var iban = "DE11231231231231"

    // MARK: - Tests methods -
    func testRequestPath() throws {
        let sut = try makeSUT(iban)
        let expectedPath = String(describing: "/iban/verify")

        XCTAssertEqual(sut.path, expectedPath, "Error with correct request path, iban value is not valid")
    }

    func testRequestHTTPMethod() throws {
        let sut = try makeSUT(iban)

        XCTAssertEqual(sut.method, .post, "Wrong IBAN request HTTP method, have to be POST")
    }

    func testRequestBody() throws {
        let sut = try makeSUT(iban)

        XCTAssertNotNil(sut.body?.httpBody, "Error with IBAN request HTTP body, body is nil")
    }

    func testRequestEmptySessionToken() throws {
        
        let sut = try makeSUT(iban)
        APIToken.sessionToken = ""
        
        XCTAssertThrowsError(try sut.asURLRequest(), "IBAN method doesn't throws empty session token error", { err in
            XCTAssertEqual(err as! RequestError, .emptySessionToken, "IBAN empty session token throws error .emptySessionToken")
        })
    }

    func testRequestEmptyIBAN() throws {
        XCTAssertThrowsError(try makeSUT(""), "Init method of IBAN request doens't handled properly empty value of the IBAN string") { error in
            XCTAssertEqual(error as! RequestError, .emptyIBAN, "IBAN request empty iban string value error is not correct, have to be .emptyIBAN")
        }
    }

    // MARK: - Internal methods -
    func makeSUT(_ iban: String) throws -> IBANRequest {
        return try IBANRequest(iban: iban)
    }
}
