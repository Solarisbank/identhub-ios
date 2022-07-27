//
//  StorageImpl.swift
//  IdentHubSDKCore
//

import Foundation

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
                return try JSONDecoder().decode(Value.self, from: data)
            } catch {
                print("Error decoding value with key \(key.name) of type \(Value.self)")
            }

            return nil
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
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
