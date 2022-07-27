//
//  FileStorage.swift
//  IdentHubSDKCore
//
import Foundation

public protocol FileStorage {
    /// Stores a file downloaded from the url with the specified file name.
    /// - Parameter url: source of the file to write
    /// - Parameter asFile: a file name to overwrite
    /// - Parameter callback: returns stored file URL
    func write(url: URL, asFile: String, callback: ((Result<URL, FileStorageError>) -> Void)?)

    func clear() throws
}

public extension FileStorage {
    func write(url: URL, callback: ((Result<URL, FileStorageError>) -> Void)?) {
        write(url: url, asFile: url.lastPathComponent, callback: callback)
    }
}

public enum FileStorageError: Error {
    case folderCreationError(Error?)
    case fileDownloadError(Error?)
    case fileWritingError(Error?)
    case folderRemovingError(Error?)
}

public struct FileStorageImpl: FileStorage {
    public let rootFolderURL: URL?

    public init(rootFolder: String) {
        rootFolderURL = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(rootFolder)
    }

    public func write(url: URL, asFile fileName: String, callback: ((Result<URL, FileStorageError>) -> Void)?) {
        guard let rootFolderURL = rootFolderURL else {
            callback?(.failure(FileStorageError.folderCreationError(nil)))
            return
        }

        do {
            try prepareFolder(with: rootFolderURL)
        } catch {
            if let error = error as? FileStorageError {
                callback?(.failure(error))
            } else {
                callback?(.failure(.folderCreationError(error)))
            }
            return
        }
        
        let pathURL = rootFolderURL.appendingPathComponent(fileName)

        getFileData(with: url) { result in
            result
                .onSuccess { data in
                    DispatchQueue.global(qos: .utility).async {
                        do {
                            try data.write(to: pathURL)
                            print("Data \(pathURL)")
                        } catch {
                            callback?(.failure(FileStorageError.fileWritingError(error)))
                            return
                        }
                        
                        callback?(.success(pathURL))
                    }
                }
                .onFailure { error in
                    callback?(.failure(error))
                }
        }
    }
    
    public func clear() throws {
        guard let rootFolderURL = rootFolderURL else {
            return
        }

        do {
            try FileManager.default.removeItem(atPath: rootFolderURL.path)
        } catch {
            throw FileStorageError.folderRemovingError(error)
        }
    }
    
    private func prepareFolder(with folderURL: URL) throws {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: folderURL.path, isDirectory: &isDirectory) == false else {
            guard isDirectory.boolValue == true else {
                throw FileStorageError.folderCreationError(nil)
            }
            return
        }

        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw FileStorageError.folderCreationError(error)
        }
    }
    
    private func getFileData(with url: URL, callback: @escaping (Result<Data, FileStorageError>) -> Void) {
        // The local file url can be a temporary file that gets deleted after the block handling it ends (see URLRequest.downloadTask) therefore we need to handle local files in the current thread while when downloading files from the network we'll dispatch it to the background thread to ensure we are not downloading network files on the main thread
        if url.isFileURL {
            getFileDataInCurrentThread(with: url, callback: callback)
        } else {
            DispatchQueue.global(qos: .utility).async {
                getFileDataInCurrentThread(with: url, callback: callback)
            }
        }
    }
    
    private func getFileDataInCurrentThread(with url: URL, callback: @escaping (Result<Data, FileStorageError>) -> Void) {
        let data: Data

        do {
            data = try Data(contentsOf: url)
            callback(.success(data))
        } catch {
            callback(.failure(FileStorageError.fileDownloadError(error)))
            return
        }
    }
}
