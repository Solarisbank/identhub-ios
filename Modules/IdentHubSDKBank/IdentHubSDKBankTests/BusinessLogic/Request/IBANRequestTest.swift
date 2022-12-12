//
//  IBANRequestTest.swift
//  IdentHubSDKBankTests
//

import XCTest
@testable import IdentHubSDKBank
import IdentHubSDKCore

final class IBANRequestTest: XCTestCase {
    
    let iban = "DE11231231231231"
    
    func testRequestPath() throws {
        let sut = try makeSUT(iban)
        let expectedPath = String(describing: "/iban/verify")

        XCTAssertEqual(sut.path, expectedPath, "IBAN request path is not valid")
    }
    
    func testRequestMethod() throws {
        let sut = try makeSUT(iban)

        XCTAssertEqual(sut.method, .post, "IBAN request HTTP methods is not correct, have to be POST")
    }
    
    func testRequestBodyIsNotNil() throws {
        let sut = try makeSUT(iban)

        XCTAssertNotNil(sut.body?.httpBody, "IBAN request HTTP body data can't be nil")
    }
    
    func testEmptySessionToken() throws {
        let sut = try makeSUT(iban)
        APIToken.sessionToken = ""
        
        XCTAssertThrowsError(try sut.asURLRequest(), "IBAN init method doesn't throws empty session token error", { err in
            XCTAssertEqual(err as! RequestError, .emptySessionToken, "IBAN empty session token throws error .emptySessionToken")
        })
    }
    
    func testEmptyIBAN() throws {
        XCTAssertThrowsError(try makeSUT(""), "IBAN init method doesn't throws empty IBAN error", { err in
            XCTAssertEqual(err as! RequestError, .emptyIBAN, "IBAN empty token error is not correct, have to be .emptyIBAN")
        })
    }

    // MARK: - Internal methods -
    func makeSUT(_ iban: String) throws -> IBANRequest {
        return try IBANRequest(iban: iban)
    }
    
}
