//
//  StorageImpl.swift
//  IdentHubSDKCore
//

import Foundation

// On iOS 12, JsonEncoding types like String directly is not possible
private struct CodableWrapper<T> : Codable where T : Codable {
    let wrapped : T
}

/// Implementation of the Storage utilizing UserDefaults suite.
public struct UserDefaultsStorage: Storage {
    private var userDefaults: UserDefaults

    public init?(suiteName: String) {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            return nil
        }
        self.userDefaults = userDefaults
    }
    
    public subscript<Value: Codable>(key: StorageKey<Value>) -> Value? {
        get {
            guard let data = userDefaults.data(forKey: key.name) else {
                return nil
            }

            do {
                if #available(iOS 13.0, *) {
                    return try JSONDecoder().decode(Value.self, from: data)
                } else {
                    let wrapper = try JSONDecoder().decode(CodableWrapper<Value>.self, from: data)
                    return wrapper.wrapped
                }
                    
            } catch {
                print("Error decoding value with key \(key.name) of type \(Value.self)")
            }

            return nil
        }
        set {
            do {
                let data: Data
                if #available(iOS 13.0, *) {
                    data = try JSONEncoder().encode(newValue)
                } else {
                    data = try JSONEncoder().encode(CodableWrapper(wrapped: newValue))
                }
                userDefaults.set(data, forKey: key.name)
            } catch {
                print("Error encoding value with key \(key.name) of type \(Value.self)")
            }
        }
    }

    public func clear() {
        userDefaults.dictionaryRepresentation().keys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
    }
}
