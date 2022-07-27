//
//  IdentificationRequest.swift
//  IdentHubSDK
//

import Foundation

public struct IdentificationRequest: BackendRequest, Equatable {

    public var path: String {
        "/identifications/\(identificationUID)"
    }

    public var method: HTTPMethod {
        .get
    }

    // MARK: Private properties

    private let identificationUID: String

    // MARK: Initializers

    /// Initializes the receiver.
    /// - Parameters:
    ///     - identificationUID: The id of the current identification.
    /// - Throws: An error of type or `RequestError.emptyIUID`
    public init(identificationUID: String) throws {

        guard identificationUID.isEmpty == false else {
            throw RequestError.emptyIUID
        }

        self.identificationUID = identificationUID
    }
}
