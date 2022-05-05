//
//  DocumentDownloadRequest.swift
//  IdentHubSDK
//

import Foundation

struct DocumentDownloadRequest: BackendRequest {

    var path: String {
        "/sign_documents/\(documentUID)/download"
    }

    var method: HTTPMethod {
        .get
    }

    // MARK: Private properties

    private let documentUID: String

    // MARK: Initializers

    /// Initializes the receiver.
    /// - Parameters:
    ///     - documentUID: The id of the current document.
    /// - Throws: An error of type or `RequestError.emptyDUID`
    init(documentUID: String) throws {

        guard documentUID.isEmpty == false else {
            throw RequestError.emptyDUID
        }

        self.documentUID = documentUID
    }
}
