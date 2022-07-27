//
//  Document.swift
//  IdentHubSDK
//

import Foundation

public struct ContractDocument: Decodable, Equatable {

    /// Id of the document.
    public let id: String

    /// Name of the document.
    public let name: String

    /// Content type of the document.
    public let contentType: String

    /// Type of the document.
    public let documentType: String

    /// Size of the document.
    public let size: Int

    /// If the document is accessible by a customer.
    public let customerAccessible: Bool

    /// When the document was created.
    public let createdAt: String

    /// When the document was deleted.
    public let deletedAt: String?

    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case contentType = "content_type"
        case documentType = "document_type"
        case size
        case customerAccessible = "customer_accessible"
        case createdAt = "created_at"
        case deletedAt = "deleted_at"
    }
}
