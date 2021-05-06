//
//  FourthlineIdentificationStatusRequest.swift
//  IdentHubSDK
//

import Foundation

final class FourthlineIdentificationStatusRequest: BackendRequest {

    // MARK: - Public attributes -

    var path: String {
        "/\(sessionToken)/identifications/\(identificationUID)"
    }

    var method: HTTPMethod {
        .get
    }

    // MARK: Private properties

    private let sessionToken: String
    private let identificationUID: String

    /// Initializes the request for defining identification method
    /// - Parameters:
    ///     - sessionToken: The token of the current session.
    ///     - uid: Identificatoin identifier of the current session.
    /// - Throws: An error of type `RequestError.emptySessioToken`, `RequestError.emptyIUID`
    init(sessionToken: String, uid: String) throws {

        guard sessionToken.isEmpty == false else {
            throw RequestError.emptySessionToken
        }

        guard uid.isEmpty == false else {
            throw RequestError.emptyIUID
        }

        self.sessionToken = sessionToken
        self.identificationUID = uid
    }
}
