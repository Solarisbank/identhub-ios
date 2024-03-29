//
//  MobileNumberTANRequest.swift
//  IdentHubSDKCore
//

import Foundation

internal struct MobileNumberTANRequest: BackendRequest, Equatable {

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
