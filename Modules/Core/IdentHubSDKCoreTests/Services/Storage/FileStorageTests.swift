//
//  FileStorageTests.swift
//  IdentHubSDKTests
//

@testable import IdentHubSDKCore
import XCTest
import IdentHubSDKTestBase

final class FileStorageTests: XCTestCase {
    static let rootFolder = "Test"
    
    func testStoreUrl() {
        let requestFile = RequestFileMock.bankDocument
        let originalData = requestFile.loadData()
        
        let sut = makeSut()
        assertAsync(timeout: 1.0) { expectation in
            sut.write(url: requestFile.url, asFile: "mockFile") { result in
                result
                    .onSuccess { localFileUrl in
                        let localData = try? Data(contentsOf: localFileUrl)

                        XCTAssertEqual(originalData, localData)
                    }
                    .onFailure { error in
                        XCTFail("Unexpected error \(error)")
                    }
                expectation.fulfill()
            }
        }
    }
    
    func testStoreNotExistingUrl() throws {
        let url = URL(string: "file://no_such_file")!
        let sut = makeSut()
        
        assertAsync(timeout: 1.0) { expectation in
            sut.write(url: url, asFile: "mockFile") { result in
                result
                    .onSuccess { _ in
                        XCTFail("Unexpected success result")
                    }
                    .onFailure { error in
                        guard case FileStorageError.fileDownloadError(_) = error else {
                            XCTFail("Unexpected error \(error)")
                            return
                        }
                    }
                expectation.fulfill()
            }
        }
    }

    func testRootFolderIsExistingFile() throws {
        let sut = makeSut()
        let fileUrl = RequestFileMock.bankDocument.url

        try Data().write(to: sut.rootFolderURL!)

        assertAsync { expectation in
            sut.write(url: fileUrl, asFile: "mockFile") { result in
                result
                    .onSuccess { _ in
                        XCTFail("Expected error")
                    }
                    .onFailure { error in
                        guard case FileStorageError.folderCreationError(_) = error else {
                            XCTFail("Unexpected error \(error)")
                            return
                        }
                    }
                expectation.fulfill()
            }
        }
    }
    
    private func makeSut(rootFolder: String = rootFolder) -> FileStorageImpl {
        let sut = FileStorageImpl(rootFolder: rootFolder)
        try? sut.clear()
        addTeardownBlock {
            try? sut.clear()
        }
        return sut
    }
}
