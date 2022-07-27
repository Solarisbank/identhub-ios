//
//  Module.swift
//  IdentHubSDKCore
//

/// Represents a module.
///
/// A module implementation should also implement it's own CoordinatorFactory.
public protocol Module: AnyObject, CoordinatorFactory {
    init(serviceLocator: ModuleServiceLocator)
}
