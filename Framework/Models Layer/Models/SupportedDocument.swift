//
//  SupportedDocument.swift
//  IdentHubSDK
//

import Foundation

struct SupportedDocument: Codable {

    /// Supported document type: passport, idcard, etc.
    let type: String

    /// Document issued countries
    let countries: [String]

    enum CodingKeys: String, CodingKey {
        case type
        case countries = "issuing_countries"
    }
}
