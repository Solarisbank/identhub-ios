//
//  DocumentsAuthorizeRequest.swift
//  IdentHubSDK
//

import Foundation

struct DocumentsAuthorizeRequest: BackendRequest {

    var path: String {
        "/\(sessionToken)/sign_documents/\(identificationUID)/authorize"
    }

    var method: HTTPMethod {
        .patch
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
