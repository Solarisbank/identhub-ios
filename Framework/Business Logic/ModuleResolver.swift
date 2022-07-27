//
//  ModuleResolver.swift
//  IdentHubSDK
//

import IdentHubSDKCore

public struct ModuleResolver {
    private let moduleFactory: ModuleFactory
    private let serviceLocator: ServiceLocator

    public lazy var qes: QESCoordinatorFactory? = {
        let moduleServiceLocator = ModuleServiceLocatorImpl(
            apiClient: serviceLocator.apiClient,
            configuration: serviceLocator.configuration,
            fileStorage: serviceLocator.modulesStorageManager.fileStorage(for: .qes),
            storage: serviceLocator.modulesStorageManager.storage(for: .qes),
            presenter: serviceLocator.presenter
        )
        return moduleFactory
            .makeQES(serviceLocator: moduleServiceLocator)
    }()
    
    init(moduleFactory: ModuleFactory, serviceLocator: ServiceLocator) {
        self.moduleFactory = moduleFactory
        self.serviceLocator = serviceLocator
    }
}
