//
//  PersonDataRequest.swift
//  IdentHubSDK
//

import UIKit

class PersonDataRequest: BackendRequest {

    // MARK: - Public attributes -

    var path: String {
        "/\(sessionToken)/identifications/\(identificationUID)/person_data"
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
    /// - Throws: An error of type `RequestError.emptySessioToken`
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
