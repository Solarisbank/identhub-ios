//
//  IdentificationInfo.swift
//  IdentHubSDK
//

import Foundation

struct IdentificationInfoRequest: BackendRequest {

    var path: String {
        "/\(sessionToken)/info"
    }

    var method: HTTPMethod {
        .get
    }

    // MARK: Private properties

    private let sessionToken: String

    // MARK: Initializers

    /// Initializes the receiver.
    /// - Parameters:
    ///     - sessionId: The token of the current session.
    /// - Throws: An error of type `RequestError.emptySessioToken`
    init(sessionToken: String) throws {
        guard sessionToken.isEmpty == false else {
            throw RequestError.emptySessionToken
        }

        self.sessionToken = sessionToken
    }
}
