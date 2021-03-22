//
//  IBANRequest.swift
//  IdentHubSDK
//

import Foundation

internal struct IBANRequest: BackendRequest {

    var path: String {
        "/\(sessionToken)/iban/verify"
    }

    var method: HTTPMethod {
        .post
    }

    var body: Body? {
        let dictionary = [
            "iban": iban
        ]

        return.json(body: dictionary)
    }

    // MARK: Private properties

    private let sessionToken: String
    private let iban: String

    // MARK: Initializers

    /// Initializes the receiver.
    /// - Parameters:
    ///     - sessionToken: The id of the current session.
    ///     - iban: The IBAN.
    /// - Throws: An error of type `RequestError.emptySessionToken` or `RequestError.emptyIBAN`
    init(sessionToken: String, iban: String) throws {

        guard sessionToken.isEmpty == false else {
            throw RequestError.emptySessionToken
        }

        guard iban.isEmpty == false else {
            throw RequestError.emptyIBAN
        }

        self.sessionToken = sessionToken
        self.iban = iban
    }
}
