//
//  HTTPMethod.swift
//  IdentHubSDKCore
//

/// A HTTP requets method.
///
/// - post: HTTP POST request.
/// - patch: HTTP PATCH request.
/// - get: HTTP GET request.
public enum HTTPMethod: String {
    case post = "POST"
    case patch = "PATCH"
    case get = "GET"
}
