//
//  UserDefaultsStorageTests.swift
//  IdentHubSDKCoreTests
//

import XCTest
@testable import IdentHubSDKCore

class UserDefaultsStorageTests: XCTestCase {
    var sut: UserDefaultsStorage!

    override func setUp() {
        sut = UserDefaultsStorage(suiteName: "Tests")
        sut.clear()
    }

    func testSetGetValues() {
        sut[.mockStringKey] = "String"
        XCTAssertEqual("String", sut[.mockStringKey])

        sut[.mockIntKey] = 666
        XCTAssertEqual(666, sut[.mockIntKey])
        
        let classSample = CodableMock()
        sut[.mockObjectKey] = classSample
        XCTAssertEqual(classSample, sut[.mockObjectKey])
    }
    
    func testRemoveValues() {
        sut[.mockStringKey] = "String"
        XCTAssertNotNil(sut[.mockStringKey])
        
        sut[.mockStringKey] = nil
        XCTAssertNil(sut[.mockStringKey])
    }

    func testClear() {
        sut[.mockStringKey] = "String"

        XCTAssertNotNil(sut[.mockStringKey])

        sut.clear()
        
        XCTAssertNil(sut[.mockStringKey])
    }
}

private extension StorageKey {
    static var mockStringKey: StorageKey<String> {
        StorageKey<String>(name: "string")
    }
    
    static var mockIntKey: StorageKey<Int> {
        StorageKey<Int>(name: "int")
    }
    
    static var mockObjectKey: StorageKey<CodableMock> {
        StorageKey<CodableMock>(name: "classSample")
    }
    
}

private class CodableMock: Codable, Equatable {
    static func == (lhs: CodableMock, rhs: CodableMock) -> Bool {
        lhs.date == rhs.date
    }
    
    let date: Date

    init() {
        date = Date()
    }
}
