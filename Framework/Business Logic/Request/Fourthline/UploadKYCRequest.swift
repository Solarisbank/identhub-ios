//
//  UploadKYCRequest.swift
//  IdentHubSDK
//

import UIKit

class UploadKYCRequest: BackendRequest {

    // MARK: - Attributes -

    var path: String {
        "/\(sessionToken)/fourthline_identification/\(sessionID)/data"
    }

    var method: HTTPMethod {
        .post
    }

    var body: Body? {
        Body.data(body: fileURL, boundary: boundary)
    }

    var headers: [String: String]? {
        return [
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]
    }

    // MARK: - Private attributes -

    private let sessionToken: String
    private let sessionID: String
    private let fileURL: URL
    private let boundary: String = "Boundary-\(UUID().uuidString)"

    init(sessionToken: String, sessionID: String, fileURL: URL) throws {
        guard sessionToken.isEmpty == false else {
            throw RequestError.emptySessionToken
        }

        guard sessionID.isEmpty == false else {
            throw RequestError.emptySessionID
        }

        self.sessionToken = sessionToken
        self.sessionID = sessionID
        self.fileURL = fileURL
    }

}
