//
//  FourthlineIdentificationStatusRequest.swift
//  IdentHubSDKFourthline
//

import Foundation
import IdentHubSDKCore

final class FourthlineIdentificationStatusRequest: BackendRequest {

    // MARK: - Public attributes -

    var path: String {
        "/identifications/\(identificationUID)"
    }

    var method: HTTPMethod {
        .get
    }

    // MARK: Private properties

    private let identificationUID: String

    /// Initializes the request for defining identification method
    /// - Parameters:
    ///     - uid: Identificatoin identifier of the current session.
    /// - Throws: An error of type `RequestError.emptyIUID`
    init(uid: String) throws {

        guard uid.isEmpty == false else {
            throw RequestError.emptyIUID
        }

        self.identificationUID = uid
    }
}
