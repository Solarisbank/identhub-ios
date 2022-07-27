//
//  URLRequestConvertible.swift
//  IdentHubSDKCore
//

import Foundation

/// Describes an entity capable of being converted into url request.
public protocol URLRequestConvertible {
    /// Returns the entity converted into url request.
    func asURLRequest() throws -> URLRequest
}
