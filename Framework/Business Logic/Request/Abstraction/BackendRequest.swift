//
//  BackendRequest.swift
//  IdentHubSDK
//

import Foundation

/// Subtype of request targeted at backend server.
protocol BackendRequest: Request {}

// MARK: Default values

extension BackendRequest {
    /// - SeeAlso: Request.basePath
    var basePath: String {
        APIPaths.backendBasePath
    }

    /// - SeeAlso: Request.apiPath
    var apiPath: String {
        APIPaths.backendApiPath
    }
}

/// - Initialization errors
public enum RequestError: Error {
    case emptySessionID
    case emptySessionToken
    case emptyIBAN
    case emptyIUID // identificationUID
    case emptyToken
    case emptyDUID // documentUID
    case invalidURL
}
