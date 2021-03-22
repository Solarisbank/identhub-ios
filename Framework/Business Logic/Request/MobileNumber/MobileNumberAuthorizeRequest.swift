//
//  AuthorizeRequest.swift
//  IdentHubSDK
//

import Foundation

struct MobileNumberAuthorizeRequest: BackendRequest {

    var path: String {
        "/\(sessionId)/mobile_number/authorize"
    }

    var method: HTTPMethod {
        .post
    }

    // MARK: Private properties

    private let sessionId: String

    // MARK: Initializers

    /// Initializes the receiver.
    /// - Parameters sessionId: The id of the current session.
    /// - Throws: An error of type `RequestError.emptySessionID`
    init(sessionId: String) throws {

        guard sessionId.isEmpty == false else {
            throw RequestError.emptySessionID
        }

        self.sessionId = sessionId
    }
}
