//
//  FourthlineIdentificationStatus.swift
//  IdentHubSDKCore
//

import Foundation

public struct FourthlineIdentificationStatus: Codable, Equatable {

    /// Id of the identification
    public let identification: String

    /// Url for identification confirmation
    public let url: String?

    /// Status of identification
    public let identificationStatus: Status

    /// Identification method type: bank, idnow, fourthline
    public let identificationMethod: IdentificationMethodType

    /// Identification request failure reason
    public let failureReason: String?

    /// Terms and conditions signed at
    public let termsSignedDate: String?

    /// Identification authorization expire date
    public let authExpireDate: String?

    /// Identification confirmation expire date
    public let confirmExpireDate: String?

    /// status code returned by fourthline identification process
    public let providerStatusCode: String?

    /// next step to continue the identification process
    public let nextStep: IdentificationStep?

    /// fallback step for trying different scenario
    public let fallbackStep: IdentificationStep?

    /// Reference tocken
    public let referenceToken: String?

    /// Reference value
    public let reference: String

    /// Identification documents
    public var documents: [ContractDocument]? = []

    enum CodingKeys: String, CodingKey {
        case identification = "id"
        case url
        case identificationStatus = "status"
        case identificationMethod = "method"
        case failureReason = "failure_reason"
        case termsSignedDate = "terms_and_conditions_signed_at"
        case authExpireDate = "authorization_expires_at"
        case confirmExpireDate = "confirmation_expires_at"
        case providerStatusCode = "provider_status_code"
        case nextStep = "next_step"
        case fallbackStep = "fallback_step"
        case referenceToken = "current_reference_token"
        case reference
        case documents
    }
}

extension FourthlineIdentificationStatus {

    public init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)

        self.identification = try data.decode(String.self, forKey: .identification)
        self.url = try data.decodeIfPresent(String.self, forKey: .url)
        self.identificationStatus = try data.decode(Status.self, forKey: .identificationStatus)
        self.identificationMethod = try data.decode(IdentificationMethodType.self, forKey: .identificationMethod)
        self.failureReason = try data.decodeIfPresent(String.self, forKey: .failureReason)
        self.termsSignedDate = try data.decodeIfPresent(String.self, forKey: .termsSignedDate)
        self.authExpireDate = try data.decodeIfPresent(String.self, forKey: .authExpireDate)
        self.confirmExpireDate = try data.decodeIfPresent(String.self, forKey: .confirmExpireDate)
        self.providerStatusCode = try data.decodeIfPresent(String.self, forKey: .providerStatusCode)
        self.nextStep = try data.decodeIfPresent(IdentificationStep.self, forKey: .nextStep)
        self.fallbackStep = try data.decodeIfPresent(IdentificationStep.self, forKey: .fallbackStep)
        self.referenceToken = try data.decodeIfPresent(String.self, forKey: .referenceToken)
        self.reference = try data.decode(String.self, forKey: .reference)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identification, forKey: .identification)
        try container.encode(identificationStatus.self.rawValue, forKey: .identificationStatus)
        try container.encode(identificationMethod.self.rawValue, forKey: .identificationMethod)
        try container.encode(failureReason, forKey: .failureReason)
        try container.encode(termsSignedDate, forKey: .termsSignedDate)
        try container.encode(authExpireDate, forKey: .authExpireDate)
        try container.encode(confirmExpireDate, forKey: .confirmExpireDate)
        try container.encode(providerStatusCode, forKey: .providerStatusCode)
        try container.encode(nextStep, forKey: .nextStep)
        try container.encode(fallbackStep, forKey: .fallbackStep)
        try container.encode(reference, forKey: .reference)
    }
}

public enum IdentificationMethodType: String, Decodable {
    case idnow = "idnow"
    case bank = "bank"
    case bankID = "bank_id"
    case fourthline = "fourthline"
    case fourthlineSigning = "fourthline_signing"
    case unknown
}
