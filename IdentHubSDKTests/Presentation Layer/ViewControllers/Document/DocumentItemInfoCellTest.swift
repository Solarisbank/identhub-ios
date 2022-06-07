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
        let content = try makeDateString(day: 18, month: 8, year: 2015)
        let sut = makeSUT(with: InfoText.issue, content: content, type: .issueDate)
        XCTAssertEqual(sut.getStatus(), .valid)
    }
    
    func testDocumentExpireDateEmpty()  throws {
        let sut = makeSUT(with: InfoText.expire, content: "", type: .expireDate)
        XCTAssertEqual(sut.getStatus(), .empty)
    }
    
    func testDocumentExpireDateInPast()  throws {
        let content = try makeDateString(day: 21, month: 5, year: 2013)
        let sut = makeSUT(with: InfoText.expire, content: content, type: .expireDate)
        XCTAssertEqual(sut.getStatus(), .pastDate)
    }
    
    func testDocumentExpireDateValid()  throws {
        let content = try makeDateString(day: 15, month: 3, year: 2024)
        let sut = makeSUT(with: InfoText.expire, content: content, type: .expireDate)
        XCTAssertEqual(sut.getStatus(), .valid)
    }
    
    // MARK: - Internal methods -
    
    private func makeDateString(day: Int, month: Int, year: Int) throws -> String {
        let components = DateComponents(calendar: Calendar(identifier: .gregorian), year: year, month: month, day: day, hour: 12)
        
        let date = try XCTUnwrap(components.date)
        
        let dateString = try XCTUnwrap(date.defaultDateString())
        
        return dateString
    }
    
    private func makeSUT(with title: String, content: String, type: DocumentItemInfoType) -> DocumentItemInfo {
        return DocumentItemInfo(title: title, content: content, type: type, prefilledDate: nil)
    }

}
