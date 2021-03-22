//
//  AppDependencies.swift
//  IdentHubSDK
//

import Foundation

/// A holder for dependencies used in the SDK.
final class AppDependencies {

    // MARK: API
    lazy var apiClient = DefaultAPIClient()

    // MARK: Services
    /// Service providing resources associated with verification.
    lazy var verificationService = VerificationService(apiClient: apiClient, sessionInfoProvider: sessionInfoProvider)

    // MARK: Storage

    /// Service providing session info.
    var sessionInfoProvider: StorageSessionInfoProvider

    // MARK: Init

    init(sessionToken: String) {
        sessionInfoProvider = StorageSessionInfoProvider(sessionToken: sessionToken)
    }
}
