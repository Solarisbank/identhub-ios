//
//  URLRequestConvertible.swift
//  IdentHubSDK
//

import Foundation

/// Describes an entity capable of being converted into url request.
protocol URLRequestConvertible {
    /// Returns the entity converted into url request.
    func asURLRequest() -> URLRequest
}
