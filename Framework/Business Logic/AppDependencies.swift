//
//  AppDependencies.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

/// A holder for dependencies used in the SDK.
final class AppDependencies {

    // MARK: Services
    /// Service providing resources associated with verification.
    lazy var verificationService = VerificationServiceImplementation(apiClient: serviceLocator.apiClient, sessionInfoProvider: sessionInfoProvider)

    lazy var serviceLocator: ServiceLocator = ServiceLocatorImpl(presenter: presenter)

    // MARK: Modules services
    lazy var moduleResolver: ModuleResolver = ModuleResolver(moduleFactory: moduleFactory, serviceLocator: serviceLocator)

    let moduleFactory: ModuleFactory
    
    // MARK: Presenter
    let presenter: Presenter

    // MARK: Storage

    /// Service providing session info.
    var sessionInfoProvider: StorageSessionInfoProvider

    // MARK: Init

    init(sessionToken: String, presenter: Presenter, moduleFactory: ModuleFactory = RuntimeModuleFactory()) {
        self.sessionInfoProvider = StorageSessionInfoProvider(sessionToken: sessionToken)
        self.presenter = presenter
        self.moduleFactory = moduleFactory
    }
    
    func updateModuleResolver() {
        moduleResolver = ModuleResolver(moduleFactory: moduleFactory, serviceLocator: serviceLocator)
    }
}
