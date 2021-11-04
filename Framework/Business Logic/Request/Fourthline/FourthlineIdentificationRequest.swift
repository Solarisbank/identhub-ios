//
//  FourthlineIdentificationRequest.swift
//  IdentHubSDK
//

import Foundation

final class FourthlineIdentificationRequest: BackendRequest {

    // MARK: - Public attributes -

    var path: String {
        "/\(sessionToken)/\(methodName)"
    }

    var method: HTTPMethod {
        .post
    }

    // MARK: Private properties
    private let sessionToken: String
    private let methodName: String

    /// Initializes the request for defining identification method
    /// - Parameters:
    ///     - sessionToken: The token of the current session.
    /// - Throws: An error of type `RequestError.emptySessioToken`
    init(sessionToken: String, method: IdentificationStep) throws {

        guard sessionToken.isEmpty == false else {
            throw RequestError.emptySessionToken
        }

        self.sessionToken = sessionToken
        self.methodName = method == .fourthlineSigning ? "fourthline_signing" : "fourthline_identification"
    }
}
