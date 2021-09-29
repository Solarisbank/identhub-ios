//
//  IdentificationInfo.swift
//  IdentHubSDK
//

import Foundation

struct IdentificationInfo: Decodable {

    /// Identification status
    let status: Status

    /// Identification callback url
    let callbackURL: String?

    /// Identification language used in SDK UI
    let language: String?

    /// Accepted status of "Terms and Conditions" agreement
    let acceptedTC: Bool

    /// Phone number verification status. Bool value defines true or false status.
    /// If phone was not verified (false) then verification screen should be the first one
    let phoneVerificationStatus: Bool?

    /// Fourthline provider string value
    let fourthlineProvider: String?

    /// Style used in SDK setup by partner
    let style: IdentificationStyle?

    enum CodingKeys: String, CodingKey {
        case status
        case callbackURL = "callback_url"
        case language
        case acceptedTC = "terms_and_conditions_pre_accepted"
        case fourthlineProvider = "fourthline_provider"
        case phoneVerificationStatus = "verified_mobile_number"
        case style
    }
}
