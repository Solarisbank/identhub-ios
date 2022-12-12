//
//  BankIDIBANRequestTest.swift
//  IdentHubSDKBankTests
//

import XCTest
@testable import IdentHubSDKBank
import IdentHubSDKCore

final class BankIDIBANRequestTest: XCTestCase {
    
    let iban = "DE11231231231231"
    
    func testRequestPath() throws {
        let sut = try makeSUT(iban)
        let expectedPath = String(describing: "/bank_id_identification")

        XCTAssertEqual(sut.path, expectedPath, "BankIDIBAN request path is not valid")
    }
    
    func testRequestMethod() throws {
        let sut = try makeSUT(iban)

        XCTAssertEqual(sut.method, .post, "BankIDIBAN request HTTP methods is not correct, have to be POST")
    }
    
    func testRequestBodyIsNotNil() throws {
        let sut = try makeSUT(iban)

        XCTAssertNotNil(sut.body?.httpBody, "BankIDIBAN request HTTP body data can't be nil")
    }
    
    func testEmptySessionToken() throws {
        let sut = try makeSUT(iban)
        APIToken.sessionToken = ""
        
        XCTAssertThrowsError(try sut.asURLRequest(), "BankIDIBAN init method doesn't throws empty session token error", { err in
            XCTAssertEqual(err as! RequestError, .emptySessionToken, "BankIDIBAN empty session token throws error .emptySessionToken")
        })
    }
    
    func testEmptyIBAN() throws {
        XCTAssertThrowsError(try makeSUT(""), "BankIDIBAN init method doesn't throws empty IBAN error", { err in
            XCTAssertEqual(err as! RequestError, .emptyIBAN, "BankIDIBAN empty token error is not correct, have to be .emptyIBAN")
        })
    }
    
    // MARK: - Internal methods -
    func makeSUT(_ iban: String) throws -> BankIDIBANRequest {
        return try BankIDIBANRequest(iban: iban)
    }
    
}
