//
//  PersonData.swift
//  IdentHubSDKFourthline
//

import Foundation
import FourthlineCore
import FourthlineKYC
import IdentHubSDKCore

struct PersonData: Codable, Equatable {

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
    
    let taxIdentification: TaxIdentification?

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
        case taxIdentification = "tax_identification"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.nationality = try container.decode(String.self, forKey: .nationality)
        
        let dateString = try container.decode(String.self, forKey: .birthDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        let date = dateFormatter.date(from: dateString)
        if let date = date {
            self.birthDate = date
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.birthDate], debugDescription: "unable to convert date string to Date object. Format not recognised", underlyingError: nil))
        }
        
        self.birthPlace = try container.decodeIfPresent(String.self, forKey: .birthPlace)
        self.personUID = try container.decode(String.self, forKey: .personUID)
        self.gender = try container.decode(Gender.self, forKey: .gender)
        self.email = try container.decode(String.self, forKey: .email)
        self.mobileNumber = try container.decode(String.self, forKey: .mobileNumber)
        self.address = try container.decode(PersonAddress.self, forKey: .address)
        self.supportedDocuments = try container.decode([SupportedDocument].self, forKey: .supportedDocuments)
        self.taxIdentification = try container.decodeIfPresent(TaxIdentification.self, forKey: .taxIdentification)
    }
    
    static func == (lhs: PersonData, rhs: PersonData) -> Bool {
        return lhs.personUID == rhs.personUID
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

public struct TaxIdentification: Codable {

    /// Person document number
    public let number: String

    /// Person country name
    public let country: String

    public enum CodingKeys: String, CodingKey {
        case number
        case country
    }
}
