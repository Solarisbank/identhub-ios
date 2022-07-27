//
//  TANRequest.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

struct MobileNumberTANRequest: BackendRequest {

    var path: String {
        "/mobile_number/confirm"
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

    private let token: String

    // MARK: Initializers

    /// Initializes the receiver.
    /// - Parameters:
    ///     - token: Token obtained to verify phone number.
    /// - Throws: An error of type `RequestError.emptyToken`
    init(token: String) throws {

        guard token.isEmpty == false else {
            throw RequestError.emptyToken
        }

        self.token = token
    }
}
