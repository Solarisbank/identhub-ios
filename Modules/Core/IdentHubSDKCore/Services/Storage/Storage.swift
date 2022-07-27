//
//  Storage.swift
//  IdentHubSDKCore
//

public struct StorageKey<Value: Codable> {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}

public protocol Storage {
    subscript<Value: Codable>(_ key: StorageKey<Value>) -> Value? { get set }
    func clear()
}
