//
//  Identification.swift
//  IdentHubSDK
//

import Foundation

public struct Identification: Decodable, Equatable {

    /// Id of the identification.
    public let id: String

    /// Reference of identification.
    public let reference: String?

    /// Url for identification confirmation.
    public let url: String?

    /// Status of identification.
    public let status: Status

    /// Date and time of identification completion.
    public let completedAt: String?

    /// method of identification; usually 'bank'.
    public let method: String

    /// Type of address verification document.
    public let proofOfAddressType: String?

    /// Issuing date of the proof of address document.
    public let proofOfAddressIssuedAt: String?

    /// IBAN of a person.
    public let iban: String?

    /// Time at which terms and conditions were signed.
    public let termsAndConditionsSignedAt: String?

    /// Time after which the identification cannot be authorized anymore.
    public let authorizationExpireAt: String?

    /// Time after which authorization must be retried.
    public let confirmationExpireAt: String?

    /// Estimated waiting time.
    public let estimatedWaitingTime: String?

    /// The address.
    public let address: String?

    /// Next step.
    public let nextStep: String?

    /// Fallback step
    public let fallbackStep: String?

    /// Provider status code
    public let providerStatusCode: String?

    /// Request failure reason
    public let failureReason: String?

    /// Current reference token
    public let referenceToken: String?

    /// Documents associated with the identification.
    public let documents: [ContractDocument]?

    public enum CodingKeys: String, CodingKey {
        case id
        case reference
        case url
        case status
        case completedAt = "completed_at"
        case method
        case proofOfAddressType = "proof_of_address_type"
        case proofOfAddressIssuedAt = "proof_of_address_issued_at"
        case iban
        case termsAndConditionsSignedAt = "terms_and_conditions_signed_at"
        case authorizationExpireAt = "authorization_expires_at"
        case confirmationExpireAt = "confirmation_expires_at"
        case estimatedWaitingTime = "estimated_waiting_time"
        case address
        case nextStep = "next_step"
        case fallbackStep = "fallback_step"
        case providerStatusCode = "provider_status_code"
        case failureReason = "failure_reason"
        case referenceToken = "current_reference_token"
        case documents
    }
}
