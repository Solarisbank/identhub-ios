//
//  ModuleFactory.swift
//  IdentHubSDKCore
//

/// Provides access to the modules coordinator factories.
public protocol ModuleFactory {
    /// Creates instance of CORE module
    func makeCore(serviceLocator: ModuleServiceLocator) -> CoreCoordinatorFactory?
    /// Creates instance of QES module
    func makeQES(serviceLocator: ModuleServiceLocator) -> QESCoordinatorFactory?
    /// Creates instance of BANK module
    func makeBank(serviceLocator: ModuleServiceLocator) -> BankCoordinatorFactory?
}
