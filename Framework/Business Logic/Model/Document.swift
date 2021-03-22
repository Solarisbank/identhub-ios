//
//  Document.swift
//  IdentHubSDK
//

import Foundation

struct Document: Decodable {

    /// Id of the document.
    let id: String

    /// Name of the document.
    let name: String

    /// Content type of the document.
    let contentType: String

    /// Type of the document.
    let documentType: String

    /// Size of the document.
    let size: Int

    /// If the document is accessible by a customer.
    let customerAccessible: Bool

    /// When the document was created.
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case contentType = "content_type"
        case documentType = "document_type"
        case size
        case customerAccessible = "customer_accessible"
        case createdAt = "created_at"
    }
}
