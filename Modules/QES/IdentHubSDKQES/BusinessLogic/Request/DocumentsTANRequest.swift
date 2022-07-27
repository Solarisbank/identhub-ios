//
//  DocumentsTANRequest.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

internal struct DocumentsTANRequest: BackendRequest, Equatable {

    var path: String {
        "/sign_documents/\(identificationUID)/confirm"
    }

    var method: HTTPMethod {
        .patch
    }

    var body: Body? {
        let dictionary = [
            "token": token
        ]

        return .json(body: dictionary)
    }

    // MARK: Private properties

    private let identificationUID: String
    private let token: String

    // MARK: Initializers

    /// Initializes the receiver.
    /// - Parameters:
    ///     - identificationUID: The id of the current identification.
    ///     - token: Token obtained to sign documents.
    /// - Throws: An error of type or `RequestError.emptyIUID` or `RequestError.emptyToken`
    init(identificationUID: String, token: String) throws {

        guard identificationUID.isEmpty == false else {
            throw RequestError.emptyIUID
        }

        guard token.isEmpty == false else {
            throw RequestError.emptyToken
        }

        self.identificationUID = identificationUID
        self.token = token
    }
}
