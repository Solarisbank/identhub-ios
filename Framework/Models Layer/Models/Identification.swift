//
//  Identification.swift
//  IdentHubSDK
//

import Foundation

struct Identification: Decodable {

    /// Id of the identification.
    let id: String

    /// Reference of identification.
    let reference: String?

    /// Url for identification confirmation.
    let url: String

    /// Status of identification.
    let status: String

    /// Date and time of identification completion.
    let completedAt: String?

    /// method of identification; usually 'bank'.
    let method: String

    /// Type of address verification document.
    let proofOfAddressType: String?

    /// Issuing date of the proof of address document.
    let proofOfAddressIssuedAt: String?

    /// IBAN of a person.
    let iban: String?

    /// Time at which terms and conditions were signed.
    let termsAndConditionsSignedAt: String?

    /// Time after which the identification cannot be authorized anymore.
    let authorizationExpireAt: String?

    /// Time after which authorization must be retried.
    let confirmationExpireAt: String?

    /// Estimated waiting time.
    let estimatedWaitingTime: String?

    /// The address.
    let address: String?

    /// Next step.
    let nextStep: String?

    /// Documents associated with the identification.
    let documents: [ContractDocument]?

    enum CodingKeys: String, CodingKey {
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
        case documents
    }
}
