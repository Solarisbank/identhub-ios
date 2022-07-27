//
//  ContractDocument.swift
//  IdentHubSDKQESTests
//

@testable import IdentHubSDKCore

internal extension ContractDocument {
    static func mock(id: String) -> ContractDocument {
        ContractDocument(
            id: id,
            name: "name",
            contentType: "content",
            documentType: "document",
            size: 0,
            customerAccessible: false,
            createdAt: "created_at",
            deletedAt: nil
        )
    }
}
