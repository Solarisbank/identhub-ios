//
//  IdentificationRequest.swift
//  IdentHubSDK
//

import Foundation

struct IdentificationRequest: BackendRequest {

    var path: String {
        "/\(sessionToken)/identifications/\(identificationUID)"
    }

    var method: HTTPMethod {
        .get
    }

    // MARK: Private properties

    private let sessionToken: String
    private let identificationUID: String

    // MARK: Initializers

    /// Initializes the receiver.
    /// - Parameters:
    ///     - sessionId: The token of the current session.
    ///     - identificationUID: The id of the current identification.
    /// - Throws: An error of type `RequestError.emptySessioToken` or `RequestError.emptyIUID`
    init(sessionToken: String, identificationUID: String) throws {

        guard sessionToken.isEmpty == false else {
            throw RequestError.emptySessionToken
        }

        guard identificationUID.isEmpty == false else {
            throw RequestError.emptyIUID
        }

        self.sessionToken = sessionToken
        self.identificationUID = identificationUID
    }
}
