//
//  Address.swift
//  IdentHubSDK
//

import Foundation

struct PersonAddress: Codable {

    /// String value of the identification person address street
    let street: String

    /// String value of the identification person address street number
    let streetNumber: String

    /// String value of the identification person address city
    let city: String

    /// String value of the identification person living address country
    let country: String

    /// String value of the identification person living address postal code
    let postalCode: String

    enum CodingKeys: String, CodingKey {
        case street
        case streetNumber = "street_number"
        case city
        case country
        case postalCode = "postal_code"
    }
}
