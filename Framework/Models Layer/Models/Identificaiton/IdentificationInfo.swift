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

    /// Fourthline provider string value
    let fourthlineProvider: String?

    enum CodingKeys: String, CodingKey {
        case status
        case callbackURL = "callback_url"
        case language
        case acceptedTC = "terms_and_conditions_pre_accepted"
        case fourthlineProvider = "fourthline_provider"
    }
}
