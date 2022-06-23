//
//  MobileNumberRequestTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class MobileNumberRequestTests: XCTestCase {

    // MARK: - Tests methods -

    func testRequestPath() throws {
        let sut = makeSUT()
        let expectedPath = String(describing: "/mobile_number")

        XCTAssertEqual(sut.path, expectedPath, "Mobile Number Request path built not correct")
    }

    func testRequestHTTPMethod() throws {
        let sut = makeSUT()
        XCTAssertEqual(sut.method, .get, "Request used wrong HTTP method, expected GET")
    }

    func testEmptySessionID() throws {
        let sut = makeSUT()
        APIToken.sessionToken = ""
        
        XCTAssertThrowsError(try sut.asURLRequest(), "Mobile Number init method doesn't throws empty session token error", { err in
            XCTAssertEqual(err as! RequestError, .emptySessionToken, "Mobile Number empty session token throws error .emptySessionToken")
        })
    }

    // MARK: - Intermal methods -
    
    func makeSUT() -> MobileNumberRequest {
        return MobileNumberRequest()
    }
}
