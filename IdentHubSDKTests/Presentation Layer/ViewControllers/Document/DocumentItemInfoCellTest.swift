//
//  DocumentItemInfoCellTest.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class DocumentItemInfoCellTest: XCTestCase {
    
    typealias InfoText = Localizable.DocumentScanner.Information
    
    func testDocumentNumberEmpty()  throws {
        let sut = makeSUT(with: InfoText.docNumber, content: "", type: .number)
        XCTAssertEqual(sut.getStatus(), .empty)
    }
    
    func testDocumentNumberValid()  throws {
        let sut = makeSUT(with: InfoText.docNumber, content: "107192637", type: .number)
        XCTAssertEqual(sut.getStatus(), .valid)
    }
    
    func testDocumentIssueDateEmpty()  throws {
        let sut = makeSUT(with: InfoText.issue, content: "", type: .issueDate)
        XCTAssertEqual(sut.getStatus(), .empty)
    }
    
    func testDocumentIssueDateValid()  throws {
        let sut = makeSUT(with: InfoText.issue, content: "Aug 18, 2015", type: .issueDate)
        XCTAssertEqual(sut.getStatus(), .valid)
    }
    
    func testDocumentExpireDateEmpty()  throws {
        let sut = makeSUT(with: InfoText.expire, content: "", type: .expireDate)
        XCTAssertEqual(sut.getStatus(), .empty)
    }
    
    func testDocumentExpireDateInPast()  throws {
        let sut = makeSUT(with: InfoText.expire, content: "Apr 21, 2013", type: .expireDate)
        XCTAssertEqual(sut.getStatus(), .pastDate)
    }
    
    func testDocumentExpireDateValid()  throws {
        let sut = makeSUT(with: InfoText.expire, content: "Mar 15, 2024", type: .expireDate)
        XCTAssertEqual(sut.getStatus(), .valid)
    }
    
    // MARK: - Internal methods -
    
    private func makeSUT(with title: String, content: String, type: DocumentItemInfoType) -> DocumentItemInfo {
        return DocumentItemInfo(title: title, content: content, type: type, prefilledDate: nil)
    }

}
