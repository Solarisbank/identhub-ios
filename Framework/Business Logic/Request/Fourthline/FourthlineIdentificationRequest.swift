//
//  FourthlineIdentificationRequest.swift
//  IdentHubSDK
//

import Foundation

final class FourthlineIdentificationRequest: BackendRequest {

    // MARK: - Public attributes -

    var path: String {
        "/\(sessionToken)/fourthline_identification"
    }

    var method: HTTPMethod {
        .post
    }

    // MARK: Private properties

    private let sessionToken: String

    /// Initializes the request for defining identification method
    /// - Parameters:
    ///     - sessionToken: The token of the current session.
    /// - Throws: An error of type `RequestError.emptySessioToken`
    init(sessionToken: String) throws {

        guard sessionToken.isEmpty == false else {
            throw RequestError.emptySessionToken
        }

        self.sessionToken = sessionToken
    }
}
