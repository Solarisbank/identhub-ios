//
//  IBANRequest.swift
//  IdentHubSDK
//

import Foundation

internal struct BankIDIBANRequest: BackendRequest {

    var path: String {
        "/bank_id_identification"
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
