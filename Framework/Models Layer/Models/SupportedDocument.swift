//
//  SupportedDocument.swift
//  IdentHubSDK
//

import Foundation

struct SupportedDocument: Codable {

    /// Supported document type: passport, idcard, etc.
    let type: SupportedDocumentType

    /// Document issued countries
    let countries: [String]

    enum CodingKeys: String, CodingKey {
        case type
        case countries = "issuing_countries"
    }
}

extension SupportedDocument {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        type = try container.decode(SupportedDocumentType.self, forKey: .type)
        countries = try container.decode([String].self, forKey: .countries)
    }

    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(type.rawValue, forKey: .type)
        try container.encode(countries, forKey: .countries)
    }
}

enum SupportedDocumentType: String, Decodable {

    case passport = "Passport"
    case idCard = "National ID Card"
    case driversLicense = "Driving License"
    case residencePermit = "Residence Permit"
    case paperId = "Paper ID"
    case frenchIdCard = "French ID Card" // Has its own document type because it has a format that differs from the national ID card common specification
    case dutchDriversLicense = "Dutch Drivers License"
}
