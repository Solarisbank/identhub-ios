//
//  SessionStorage.swift
//  SessionStorage
//
//  Created by admin on 11.05.2021.
//

import Foundation

/// Stored values key to the UserDefaults. Used for future clean up
let kStoredValueKeys = "StoredValueKeys"

/// User defaults storage adapter
/// Class used for saving/updating value in UserDefaults and also clear all stored data
public enum SessionStorage {

    /// Method stored value to the UserDefaults by key. T - type of the stored value.
    /// Also method stored value key for the future clean up
    /// - Parameters:
    ///   - value: stored value with generic type <T>
    ///   - key: stored value key
    public static func updateValue(_ value: Any, for key: String) {
        UserDefaults.standard.setValue(value, forKey: key)
        storeKey(key: key)
        UserDefaults.standard.synchronize()
    }

    /// Method fetched value from user defaults
    /// - Parameter key: stored value key
    /// - Returns: optional stored value with generic type T
    public static func obtainValue(for key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }

    /// Method removes all session data
    public static func clearData() {
        SessionStorage.removeDataFromDefaults()
        SessionStorage.removeTemporaryFiles()
    }

    /// Method removed object for key
    /// - Parameter key: stored object key
    public static func deleteObject(for key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
}

private extension SessionStorage {

    static func storeKey(key: String) {
        if var storedKeys = UserDefaults.standard.value(forKey: kStoredValueKeys) as? [String] {
            storedKeys.append(key)
            UserDefaults.standard.setValue(storedKeys, forKey: kStoredValueKeys)
        } else {
            UserDefaults.standard.setValue([key], forKey: kStoredValueKeys)
        }
    }

    static func removeDataFromDefaults() {
        if let storedKeys = UserDefaults.standard.value(forKey: kStoredValueKeys) as? [String] {

            for key in storedKeys {
                UserDefaults.standard.removeObject(forKey: key)
            }

            UserDefaults.standard.removeObject(forKey: kStoredValueKeys)

            UserDefaults.standard.synchronize()
        }
    }

    static func removeTemporaryFiles() {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())

            for item in contents {
                let filePath = NSTemporaryDirectory() + item

                try FileManager.default.removeItem(atPath: filePath)
            }
        } catch let error {
            print("Error with fetching data from Temporary folder: \(error.localizedDescription)")
        }
    }
}
