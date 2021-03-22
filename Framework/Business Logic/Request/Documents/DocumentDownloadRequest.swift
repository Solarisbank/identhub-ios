//
//  DocumentDownloadRequest.swift
//  IdentHubSDK
//

import Foundation

struct DocumentDownloadRequest: BackendRequest {

    var path: String {
        "/\(sessionToken)/sign_documents/\(documentUID)/download"
    }

    var method: HTTPMethod {
        .get
    }

    // MARK: Private properties

    private let sessionToken: String
    private let documentUID: String

    // MARK: Initializers

    /// Initializes the receiver.
    /// - Parameters:
    ///     - sessionToken: The token of the current session.
    ///     - documentUID: The id of the current document.
    /// - Throws: An error of type `RequestError.emptySessioToken` or `RequestError.emptyDUID`
    init(sessionToken: String, documentUID: String) throws {

        guard sessionToken.isEmpty == false else {
            throw RequestError.emptySessionToken
        }

        guard documentUID.isEmpty == false else {
            throw RequestError.emptyDUID
        }

        self.sessionToken = sessionToken
        self.documentUID = documentUID
    }
}
