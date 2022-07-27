//
//  StorageMock.swift
//  IdentHubSDKTestBase
//
import IdentHubSDKCore

public final class StorageMock: Storage {
    public private(set) var values = [String: Any]()

    public init() {}

    public subscript<Value>(key: StorageKey<Value>) -> Value? where Value: Decodable, Value: Encodable {
        get {
            values[key.name] as? Value
        }
        set {
            values[key.name] = newValue
        }
    }

    public func clear() {
        values.removeAll()
    }
}
