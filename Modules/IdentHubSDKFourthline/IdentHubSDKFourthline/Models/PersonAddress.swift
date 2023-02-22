//
//  PersonAddress.swift
//  IdentHubSDKFourthline
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

extension PersonAddress {
    
    func parseStreetNumber() -> StreetNumber {
        let numberMatches = streetNumber.matches(for: String.streetNumberRegex)
        let suffixMatches = streetNumber.matches(for: String.streetNumberSuffixRegex)
        guard let numberSring = numberMatches.first, let number = NumberFormatter().number(from: numberSring)?.intValue else {
            return StreetNumber(number: 0, suffix: suffixMatches.first)
        }
        
        return StreetNumber(number: number, suffix: suffixMatches.first)
    }
}

struct StreetNumber {
    let number: Int
    let suffix: String?
}

