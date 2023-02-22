//
//  FourthlineIdentification.swift
//  IdentHubSDKFourthline

import UIKit

class FourthlineIdentification: Decodable {

    let identificationID: String

    let reference: String

    let url: String?

    let identificationStatus: String

    let completionDate: String?

    let identificationMethod: String

    let addressType: String?

    let addressIssued: String?

    let iban: String?

    let termsSignedDate: Bool?

    let expirationDate: String?

    let confirmationDate: String?

    let statusCode: String?

    let waitingTime: Int?

    enum CodingKeys: String, CodingKey {
        case identificationID = "id"
        case reference
        case url
        case identificationStatus = "status"
        case completionDate = "completed_at"
        case identificationMethod = "method"
        case addressType = "proof_of_address_type"
        case addressIssued = "proof_of_address_issued_at"
        case iban
        case termsSignedDate = "terms_and_conditions_signed_at"
        case expirationDate = "authorization_expires_at"
        case confirmationDate = "confirmation_expires_at"
        case statusCode = "provider_status_code"
        case waitingTime = "estimated_waiting_time"
    }
}
