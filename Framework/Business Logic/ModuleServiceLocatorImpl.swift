//
//  ModuleServiceLocatorImpl.swift
//  IdentHubSDK
//

import IdentHubSDKCore

struct ModuleServiceLocatorImpl: ModuleServiceLocator {
    let apiClient: APIClient
    let configuration: Configuration
    let fileStorage: FileStorage
    let storage: Storage
    let presenter: Presenter
    
    init(
        apiClient: APIClient,
        configuration: Configuration,
        fileStorage: FileStorage,
        storage: Storage,
        presenter: Presenter
    ) {
        self.apiClient = apiClient
        self.configuration = configuration
        self.presenter = presenter
        self.fileStorage = fileStorage
        self.storage = storage
    }
}
