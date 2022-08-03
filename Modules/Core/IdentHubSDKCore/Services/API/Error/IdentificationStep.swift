//
//  IdentificationStep.swift
//  IdentHubSDKCore
//

/// Identification steps
public enum IdentificationStep: String, Codable, CaseIterable {
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
    
    public init(from decoder: Decoder) throws {
        self = try IdentificationStep(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unspecified
    }
}
