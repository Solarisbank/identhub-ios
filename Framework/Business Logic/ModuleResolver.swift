//
//  ModuleResolver.swift
//  IdentHubSDK
//

import IdentHubSDKCore

internal class ModuleResolver {
    private let moduleFactory: ModuleFactory
    private let serviceLocator: ServiceLocator

    var availableModules: Set<ModuleName> {
        ModuleName.allCases.map { moduleName in self[moduleName] != nil ? moduleName : nil }
            .compactMap { $0 }
            .asSet()
    }

    subscript(name: ModuleName) -> CoordinatorFactory? {
        switch name {
        case .qes: return qes
        }
    }

    lazy var qes: QESCoordinatorFactory? = {
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
