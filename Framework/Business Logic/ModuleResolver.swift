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
        case .core: return core
        case .qes: return qes
        case .fourthline: return fourthline
        case .bank: return bank
        }
    }
    
    func moduleServiceLocator(module: ModuleName) -> ModuleServiceLocator {
        return ModuleServiceLocatorImpl(
            apiClient: serviceLocator.apiClient,
            configuration: serviceLocator.configuration,
            fileStorage: serviceLocator.modulesStorageManager.fileStorage(for: module),
            storage: serviceLocator.modulesStorageManager.storage(for: module),
            presenter: serviceLocator.presenter
        )
    }
    
    lazy var core: CoreCoordinatorFactory? = {
        return moduleFactory
            .makeCore(serviceLocator: moduleServiceLocator(module: .core))
    }()

    lazy var qes: QESCoordinatorFactory? = {
        return moduleFactory
            .makeQES(serviceLocator: moduleServiceLocator(module: .qes))
    }()
    
    lazy var bank: BankCoordinatorFactory? = {
        return moduleFactory
            .makeBank(serviceLocator: moduleServiceLocator(module: .bank))
    }()

    lazy var fourthline: FourthlineCoordinatorFactory? = {
        return moduleFactory
            .makeFourthline(serviceLocator: moduleServiceLocator(module: .fourthline))
    }()

    init(moduleFactory: ModuleFactory, serviceLocator: ServiceLocator) {
        self.moduleFactory = moduleFactory
        self.serviceLocator = serviceLocator
    }
}
