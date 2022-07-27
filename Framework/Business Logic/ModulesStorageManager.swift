//
//  ModulesStorageManager.swift
//  IdentHubSDK
//
import IdentHubSDKCore

final class ModulesStorageManager {
    private var storages = [ModuleName: Storage]()
    private var fileStorages = [ModuleName: FileStorage]()
    
    init() {
        ModuleName.allCases.forEach { addStorages(for: $0) }
    }
    
    func storage(for moduleName: ModuleName) -> Storage {
        guard let storage = storages[moduleName] else {
            fatalError("Storage for module \(moduleName) not created")
        }
        return storage
    }
    
    func fileStorage(for moduleName: ModuleName) -> FileStorage {
        guard let fileStorage = fileStorages[moduleName] else {
            fatalError("Storage for module \(moduleName) not created")
        }
        return fileStorage
    }
    
    func clearAllData() {
        storages.values.forEach { $0.clear() }
        fileStorages.values.forEach { fileStorage in
            do {
                try fileStorage.clear()
            } catch {
                print("Error! Couldn't clear file storage \(error)")
            }
        }
    }
    
    private func addStorages(for moduleName: ModuleName) {
        storages[moduleName] = UserDefaultsStorage(suiteName: moduleName.rawValue)
        fileStorages[moduleName] = FileStorageImpl(rootFolder: moduleName.rawValue)
    }
}
