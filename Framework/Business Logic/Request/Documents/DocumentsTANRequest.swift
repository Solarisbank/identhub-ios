//
//  DocumentsTANRequest.swift
//  IdentHubSDK
//

import Foundation

struct DocumentsTANRequest: BackendRequest {

    var path: String {
        "/\(sessionToken)/sign_documents/\(identificationUID)/confirm"
    }

    var method: HTTPMethod {
        .patch
    }

    var body: Body? {
        let dictionary = [
            "token": token
        ]

        return.json(body: dictionary)
    }

    // MARK: Private properties

    private let sessionToken: String
    private let identificationUID: String
    private let token: String

    // MARK: Initializers

    /// Initializes the receiver.
    /// - Parameters:
    ///     - sessionId: The token of the current session.
    ///     - identificationUID: The id of the current identification.
    ///     - token: Token obtained to sign documents.
    /// - Throws: An error of type `RequestError.emptySessioToken` or `RequestError.emptyIUID` or `RequestError.emptyToken`
    init(sessionToken: String, identificationUID: String, token: String) throws {

        guard sessionToken.isEmpty == false else {
            throw RequestError.emptySessionToken
        }

        guard identificationUID.isEmpty == false else {
            throw RequestError.emptyIUID
        }

        guard token.isEmpty == false else {
            throw RequestError.emptyToken
        }

        self.sessionToken = sessionToken
        self.identificationUID = identificationUID
        self.token = token
    }
}
