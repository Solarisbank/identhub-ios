//
//  IdentificationMethodRequest.swift
//  IdentHubSDK
//

import Foundation

final class IdentificationMethodRequest: BackendRequest {

    // MARK: - Public attributes -

    var path: String {
        "/\(sessionToken)/"
    }

    var method: HTTPMethod {
        .get
    }

    // MARK: Private properties

    private let sessionToken: String

    /// Initializes the request for defining identification method
    /// - Parameters:
    ///     - sessionToken: The token of the current session.
    /// - Throws: An error of type `RequestError.emptySessioToken`
    init(sessionToken: String) throws {

        guard sessionToken.isEmpty == false else {
            throw RequestError.emptySessionToken
        }

        self.sessionToken = sessionToken
    }
}
