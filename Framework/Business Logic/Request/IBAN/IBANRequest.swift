//
//  IBANRequest.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

internal struct IBANRequest: BackendRequest {

    var path: String {
        "/iban/verify"
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

    private let iban: String

    // MARK: Initializers

    /// Initializes the receiver.
    /// - Parameters:
    ///     - iban: The IBAN.
    /// - Throws: An error of type `RequestError.emptyIBAN`
    init(iban: String) throws {

        guard iban.isEmpty == false else {
            throw RequestError.emptyIBAN
        }

        self.iban = iban
    }
}
