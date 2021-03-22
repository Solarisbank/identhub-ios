//
//  TANRequest.swift
//  IdentHubSDK
//

import Foundation

struct MobileNumberTANRequest: BackendRequest {

    var path: String {
        "/\(sessionId)/mobile_number/confirm"
    }

    var method: HTTPMethod {
        .post
    }

    var body: Body? {
        let dictionary = [
            "token": token
        ]

        return .json(body: dictionary)
    }

    // MARK: Private properties

    private let sessionId: String
    private let token: String

    // MARK: Initializers

    /// Initializes the receiver.
    /// - Parameters:
    ///     - sessionId: The id of the current session.
    ///     - token: Token obtained to verify phone number.
    /// - Throws: An error of type `RequestError.emptySessionID` or `RequestError.emptyToken`
    init(sessionId: String, token: String) throws {

        guard sessionId.isEmpty == false else {
            throw RequestError.emptySessionID
        }

        guard token.isEmpty == false else {
            throw RequestError.emptyToken
        }

        self.sessionId = sessionId
        self.token = token
    }
}
