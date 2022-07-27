//
//  FileStorageMock.swift
//  IdentHubSDKQESTests
//
import IdentHubSDKCore
import Foundation

public struct FileStorageMock: FileStorage {
    public init() {}

    public func write(url: URL, asFile: String, callback: ((Result<URL, FileStorageError>) -> Void)?) {
        callback?(.success(url))
    }
    
    public func clear() throws {}
}
