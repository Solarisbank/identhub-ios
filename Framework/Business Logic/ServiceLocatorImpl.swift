//
//  ServiceLocatorImpl.swift
//  IdentHubSDK
//

import IdentHubSDKCore

struct ServiceLocatorImpl: ServiceLocator {
    let apiClient: APIClient
    
    var configuration: Configuration
    let presenter: Presenter
    let modulesStorageManager: ModulesStorageManager

    init(
        presenter: Presenter,
        apiClient: APIClient = DefaultAPIClient(),
        configuration: Configuration = Configuration(colors: ColorsImpl())
    ) {
        self.apiClient = apiClient
        self.configuration = configuration
        self.presenter = presenter
        self.modulesStorageManager = ModulesStorageManager()
    }
}
