//
//  PersonData.swift
//  IdentHubSDKFourthline
//

import Foundation
import FourthlineCore
import FourthlineKYC
import IdentHubSDKCore

struct PersonData: Codable {

    /// Identification person first name
    var firstName: String

    /// Identification person last name
    var lastName: String

    /// Identification person nationality abbreviation: US, DE, etc.
    var nationality: String

    /// String value of the identification person birth day: yyyy-mm-dd
    var birthDate: Date

    /// String value of the identificatioin person bith place
    let birthPlace: String?

    /// Identification value of the person
    let personUID: String

    /// String value of the person gender
    let gender: Gender

    /// String value of the user email
    let email: String

    /// String value of the mobile number
    let mobileNumber: String

    /// Address object of the living/register person's place
    let address: PersonAddress

    /// Array of the supported documents for person nationality
    let supportedDocuments: [SupportedDocument]

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case nationality
        case birthDate = "birth_date"
        case birthPlace = "place_of_birth"
        case personUID = "person_uid"
        case gender
        case email
        case mobileNumber = "mobile_number"
        case address
        case supportedDocuments = "supported_documents"
    }
}

// MARK: - Updating methods -

extension PersonData {

    /// Method update person data with info obtained from scanned document
    /// - Parameter mrzInfo: scanned document info
    mutating func update(with mrzInfo: MRTDMRZInfo) {

        firstName = mrzInfo.firstNames.joined(separator: " ")
        lastName = mrzInfo.lastNames.joined(separator: " ")
        birthDate = mrzInfo.birthDate
        if CountryCodes.isSupported(country: mrzInfo.nationality) {
            nationality = mrzInfo.nationality
        }
    }
}

enum Gender: String, Codable {
    case male = "male"
    case female = "female"
    case unknown = "unknown"
}
