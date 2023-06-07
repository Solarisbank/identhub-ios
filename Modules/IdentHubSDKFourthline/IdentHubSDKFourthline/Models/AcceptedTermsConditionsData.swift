//
//  AcceptedTermsConditionsData.swift
//  IdentHubSDKFourthline
//
//  Created by Abhijit Soni on 02/06/23.
//

import Foundation

struct AcceptedTermsConditionsData: Decodable, Equatable {

    /// Device requested IP-address value
    let id: String
    let eventType: String
    let signedBy: String
    let signedOnBehalfOf: String
    let documentId: String
    let productName: String
    let timeStamp: String
    let cratedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case eventType = "event_type"
        case signedBy = "signed_by"
        case signedOnBehalfOf = "signed_on_behalf_of"
        case productName = "product_name"
        case documentId = "document_id"
        case timeStamp = "event_timestamp"
        case cratedAt = "created_at"
    }
}
