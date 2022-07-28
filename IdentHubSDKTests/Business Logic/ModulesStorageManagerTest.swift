//
//  ModulesStorageManagerTest.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK
import IdentHubSDKTestBase
import IdentHubSDKCore

class ModulesStorageManagerTests: XCTestCase {
    let storageTestKeyValue = "Test"

    func testSetAndClearAllData() {
        let sut = makeSut()
        var writtenPaths = [ModuleName: String]()
        
        ModuleName.allCases.forEach { moduleName in
            var storage = sut.storage(for: moduleName)
            let fileStorage = sut.fileStorage(for: moduleName)

            storage[.testKey] = storageTestKeyValue
            assertAsync(timeout: 1.0) { expectation in
                fileStorage.write(url: RequestFileMock.bankDocument.url, asFile: "mockFile") { result in
                    result
                        .onSuccess { url in
                            writtenPaths[moduleName] = url.path
                        }
                        .onFailure { error in
                            XCTFail("Unexpected error \(error)")
                        }
                    expectation.fulfill()
                }
            }
        }
        
        ModuleName.allCases.forEach { moduleName in
            XCTAssertEqual(sut.storage(for: moduleName)[.testKey], storageTestKeyValue)
            XCTAssertTrue(FileManager.default.fileExists(atPath: writtenPaths[moduleName]!))
        }

        sut.clearAllData()

        ModuleName.allCases.forEach { moduleName in
            XCTAssertNil(sut.storage(for: moduleName)[.testKey])
            XCTAssertFalse(FileManager.default.fileExists(atPath: writtenPaths[moduleName]!))
        }
    }
    
    func makeSut() -> ModulesStorageManager {
        ModulesStorageManager()
    }
}

private extension StorageKey {
    static var testKey: StorageKey<String> {
        StorageKey<String>(name: "testKey")
    }
}
