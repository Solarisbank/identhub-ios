//
//  IdentificationRequest.swift
//  IdentHubSDK
//

import Foundation

struct IdentificationRequest: BackendRequest {

    var path: String {
        "/identifications/\(identificationUID)"
    }

    var method: HTTPMethod {
        .get
    }

    // MARK: Private properties

    private let identificationUID: String

    // MARK: Initializers

    /// Initializes the receiver.
    /// - Parameters:
    ///     - identificationUID: The id of the current identification.
    /// - Throws: An error of type or `RequestError.emptyIUID`
    init(identificationUID: String) throws {

        guard identificationUID.isEmpty == false else {
            throw RequestError.emptyIUID
        }

        self.identificationUID = identificationUID
    }
}
