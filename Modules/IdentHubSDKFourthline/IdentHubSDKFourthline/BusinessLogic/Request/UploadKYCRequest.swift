//
//  UploadKYCRequest.swift
//  IdentHubSDKFourthline
//

import UIKit
import IdentHubSDKCore

class UploadKYCRequest: BackendRequest {

    // MARK: - Attributes -

    var path: String {
        "/fourthline_identification/\(sessionID)/data"
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

    // MARK: Private properties

    private let sessionID: String
    private let fileURL: URL
    private let boundary: String

    init(sessionID: String, fileURL: URL) throws {

        guard sessionID.isEmpty == false else {
            throw RequestError.emptySessionID
        }
        
        let uuidString = UUID().uuidString
        
        guard uuidString.isEmpty == false else {
            throw RequestError.invalidBoundary
        }

        self.sessionID = sessionID
        self.fileURL = fileURL
        self.boundary = uuidString
    }

}
