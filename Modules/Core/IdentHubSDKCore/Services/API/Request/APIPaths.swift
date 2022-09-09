//
//  APIPaths.swift
//  IdentHubSDKCore
//

import Foundation

/// Container for API paths.
public enum APIPaths {

    // MARK: Backend

    /// Base path for backend API.
    public static var backendBasePath = ""

    /// Environment path for backend API.
    public static let backendApiPath = "/person_onboarding"
    
    public static var backendApiURL: URL? {
        URL(string: backendBasePath)?.appendingPathComponent(backendApiPath)
    }
    
}

/// Container for API Session token.
public enum APIToken {
    
    /// API Session token pass as header.
    public static var sessionToken = ""
}
