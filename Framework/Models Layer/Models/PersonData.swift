//
//  PersonData.swift
//  IdentHubSDK
//

import Foundation

struct PersonData: Decodable {

    /// Identification person first name
    let firstName: String

    /// Identification person last name
    let lastName: String

    /// Identification person nationality abbreviation: US, DE, etc.
    let nationality: String

    /// String value of the identification person birth day: yyyy-mm-dd
    let birthDate: Date

    /// Identification value of the person
    let personUID: String

    /// String value of the person gender
    let gender: String

    /// Array of the supported documents for person nationality
    let supportedDocuments: [SupportedDocument]

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case nationality
        case birthDate = "birth_date"
        case personUID = "person_uid"
        case gender
        case supportedDocuments = "supported_documents"
    }
}
