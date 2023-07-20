//
//  IdentificationInfo.swift
//  IdentHubSDKCore
//

import Foundation

public struct IdentificationInfo: Decodable, Equatable {
  
    /// Identification status
    public let status: Status

    /// Identification callback url
    public let callbackURL: String?

    /// Identification language used in SDK UI
    public let language: String?

    /// Accepted status of "Terms and Conditions" agreement
    public let acceptedTC: Bool

    /// Phone number verification status. Bool value defines true or false status.
    /// If phone was not verified (false) then verification screen should be the first one
    public let phoneVerificationStatus: Bool?
    
    /// Secondary Document scaning status. Bool value defines true or false status.
    /// If Secondary document(Health card) is required then scan second document and update KYC Zip. 
    public let isSecondaryDocScanRequired: Bool?

    /// Fourthline provider string value
    public let fourthlineProvider: String?

    /// Style used in SDK setup by partner
    public let style: IdentificationStyle?
    
    /// If `true` remote logging should be enabled with `.warn` level
    public let remoteLogging: Bool?
    
    /// If `true' open ORCA flow for document scanning `
    public let orcaEnabled: Bool?

    public enum CodingKeys: String, CodingKey {
        case status
        case callbackURL = "callback_url"
        case language
        case acceptedTC = "terms_and_conditions_pre_accepted"
        case fourthlineProvider = "fourthline_provider"
        case phoneVerificationStatus = "verified_mobile_number"
        case isSecondaryDocScanRequired = "secondary_document_required"
        case style
        case remoteLogging = "sdk_logging"
        case orcaEnabled = "orca_enabled"
    }
    
    public static func == (lhs: IdentificationInfo, rhs: IdentificationInfo) -> Bool {
        return lhs.status == rhs.status
    }
}
