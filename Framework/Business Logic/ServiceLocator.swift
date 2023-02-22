//
//  ServiceLocator.swift
//  IdentHubSDKCore
//
import Foundation
import IdentHubSDKCore

public enum ModuleName: String, CaseIterable {
    case core
    case qes
    case fourthline
    case bank
}

/// Provides access to services.
protocol ServiceLocator {
    var apiClient: APIClient { get }
    var configuration: Configuration { get set }
    var presenter: Presenter { get }
    var modulesStorageManager: ModulesStorageManager { get }
}
