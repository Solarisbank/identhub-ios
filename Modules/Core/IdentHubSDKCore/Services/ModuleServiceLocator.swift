//
//  ModuleServiceLocator.swift
//  IdentHubSDKCore
//

/// Provides access to services for a module.
public protocol ModuleServiceLocator {
    var apiClient: APIClient { get }
    var configuration: Configuration { get }
    var fileStorage: FileStorage { get }
    var storage: Storage { get }
    var presenter: Presenter { get }
}
