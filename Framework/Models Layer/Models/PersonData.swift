//
//  PersonData.swift
//  IdentHubSDK
//

import Foundation
import FourthlineCore

struct PersonData: Codable {

    /// Identification person first name
    var firstName: String

    /// Identification person last name
    var lastName: String

    /// Identification person nationality abbreviation: US, DE, etc.
    var nationality: String

    /// String value of the identification person birth day: yyyy-mm-dd
    var birthDate: Date

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

// MARK: - Updating methods -

extension PersonData {

    /// Method update person data with info obtained from scanned document
    /// - Parameter mrzInfo: scanned document info
    mutating func update(with mrzInfo: MRTDMRZInfo) {

        firstName = mrzInfo.firstNames.joined(separator: " ")
        lastName = mrzInfo.lastNames.joined(separator: " ")
        birthDate = mrzInfo.birthDate
        nationality = mrzInfo.nationality
    }
}

