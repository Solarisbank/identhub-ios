//
//  APIPaths.swift
//  IdentHubSDK
//

import Foundation

/// Container for API paths.
enum APIPaths {

    // MARK: Backend

    /// Base path for backend API.
    #if ENV_DEBUG
    static let backendBasePath = "https://person-onboarding-api.solaris-testing.de"
    #else
    static let backendBasePath = ""
    #endif
    /// Environment path for backend API.
    static let backendApiPath = "/person_onboarding"
}
