//
//  FourthlineIdentificationRequest.swift
//  IdentHubSDKFourthline
//

import Foundation
import IdentHubSDKCore

final class FourthlineIdentificationRequest: BackendRequest {

    // MARK: - Public attributes -

    var path: String {
        "/\(methodName)"
    }

    var method: HTTPMethod {
        .post
    }

    // MARK: Private properties

    private let methodName: String

    /// Initializes the request for defining identification method
    /// - Parameters:
    /// - Throws: An error of type `RequestError.emptySessioToken`
    init(method: IdentificationStep) throws {

        self.methodName = method == .fourthlineSigning ? "fourthline_signing" : "fourthline_identification"
    }
}
