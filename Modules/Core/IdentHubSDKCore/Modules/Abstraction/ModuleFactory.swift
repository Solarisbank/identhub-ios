//
//  ModuleFactory.swift
//  IdentHubSDKCore
//

/// Provides access to the modules coordinator factories.
public protocol ModuleFactory {
    /// Creates instance of QES module
    func makeQES(serviceLocator: ModuleServiceLocator) -> QESCoordinatorFactory?
}
