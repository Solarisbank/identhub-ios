//
//  PersonDataRequest.swift
//  IdentHubSDKFourthline

import Foundation
import IdentHubSDKCore

class PersonDataRequest: BackendRequest {

    // MARK: - Public attributes -

    var path: String {
        "/identifications/\(identificationUID)/person_data\(isOrca ? "?raw=true" : "")"
    }

    var method: HTTPMethod {
        .get
    }

    // MARK: Private properties

    private let identificationUID: String
    private let isOrca: Bool

    /// Initializes the request for defining identification method
    /// - Parameters:
    ///     - uid: Identificatoin identifier of the current session.
    /// - Throws: An error of type `RequestError.emptyIUID`
    init(uid: String, isOrca: Bool) throws {

        guard uid.isEmpty == false else {
            throw RequestError.emptyIUID
        }

        self.identificationUID = uid
        self.isOrca = isOrca
    }
}
