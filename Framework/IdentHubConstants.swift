//
//  IdentHubConstants.swift
//  IdentHubSDK
//

import Foundation

/// Ident hub session result
public enum IdentificationSessionResult {
    /// success - successful result with identification string in parameter
    /// - identification: identification user session identifier
    case success(identification: String)

    /// failure - the session has failed for some reason.
    /// - error: indicating the reason of the failure. Kept for backwards compatibility, integrators should not rely on the specifics of the error.
    case failure(APIError)

    /// onConfirm - success result of the Fourthline signing flow with identification value string in parameter
    /// - identification: identification user session identifier
    case onConfirm(identification: String)
}

/// UserDefaults stored keys
enum StoredKeys: String {

    /// Stored initial step in UserDefaults string key
    case initialStep = "InitialSessionStepKey"

    /// Stored identification session method type key
    case identMethod = "IdentificationSessionMethodKey"

    /// Session token key 
    case token = "SessionTokenKey"

    /// Mobile number of the identification user key
    case mobileNumber = "UserMobileNumberKey"

    /// Session identification value key
    case identUID = "IdentificationUIDKey"

    /// Session identification path value key
    case identPath = "IdentificationSessionPathKey"

    /// Fallback session identification path value key
    case identStep = "IdentificationSessionStepKey"

    /// Fallback session identification path value key
    case fallbackIdentStep = "FallbackIdentificationSessionStepKey"

    /// Retries IBAN registration amount
    case retriesCount = "IdentRetriesCountKey"

    /// Accepted state of the "Terms and Conditions" agreement
    case acceptedTC = "TermsAndConditionsAcceptedKey"

    /// Status of the phone verification
    case phoneVerified = "PhoneVerificationStatusKey"

    /// BankID identification session process step value key
    case bankIDStep = "BankIDIdentificationStepKey"

    /// Personal data value key
    case personData = "IndentificationPersonDataKey"

    /// Fourthline provider data key
    case providerData = "FourthlineProviderDataKey"

    /// Device IP-address data key
    case ipAddressData = "IPAddressDataKey"

    /// Prepare users data
    case fetchDataStep = "FetchPersonDataProcessKey"

    /// Identification UI colors
    case styleColors = "IdentificationUIColorsKey"

    /// Style colors keys enumeration
    enum StyleColor: String {

        case primary = "PrimaryLightColorKey"

        case primaryDark = "PrimaryDarkColorKey"

        case secondary = "SecondaryLightColorKey"
    }
}

/// Enumeration with all Fourthline flow steps
enum FourthlineProgressStep: Int {
    case selfie = 0, document, confirm, upload, result
}

/// Identification steps
enum IdentificationStep: String, Codable {
    case mobileNumber = "mobile_number"
    case bankIBAN = "bank/iban"
    case bankIDIBAN = "bank_id/iban"
    case bankIDFourthline = "bank_id/fourthline"
    case bankQES = "bank/qes"
    case bankIDQES = "bank_id/qes"
    case fourthline = "fourthline/simplified"
    case fourthlineSigning = "fourthline_signing"
    case fourthlineQES = "fourthline_signing/qes"
    case abort = "abort"
    case partnerFallback = "partner_fallback"
    case unspecified
    
    init(from decoder: Decoder) throws {
        self = try IdentificationStep(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unspecified
    }
}
