//
//  UploadFourthlineZip.swift
//  IdentHubSDKFourthline
//

import UIKit

class UploadFourthlineZip: Decodable, Equatable {

    /// Uploaded document identifier
    let identifier: String

    /// Uploaded document name
    let name: String

    /// Uploaded document content type
    let contentType: String

    /// Uploaded document type
    let documentType: String

    /// Uploaded document size
    let documentSize: Int

    /// Customer accessibility of the uploaded document
    let accessibility: Bool

    /// Create document on server date
    let createDate: String

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case contentType = "content_type"
        case documentType = "document_type"
        case documentSize = "size"
        case accessibility = "customer_accessible"
        case createDate = "created_at"
    }
    
    static func == (lhs: UploadFourthlineZip, rhs: UploadFourthlineZip) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
