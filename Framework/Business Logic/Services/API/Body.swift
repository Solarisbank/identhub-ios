//
//  Body.swift
//  IdentHubSDK
//

import Foundation

/// Represents body sent in the url request.
///
/// - json: compliant with application/json encoding.
enum Body {
    case json(body: [String: Any])

    // MARK: Properties

    /// Returns the body encoded into data.
    var httpBody: Data? {
        switch self {
        case let .json(body):
            do {
                return try Body.createJson(body: body)
            } catch let error as NSError {
                print("Serilizationtion body dictionary to JSON throws error: \(error.localizedDescription)")
                return nil
            }
        }
    }

    // MARK: Private methods
    private static func createJson(body: [String: Any]) throws -> Data? {
        try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
    }
}
