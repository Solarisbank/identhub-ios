//
//  FourthlineIdentificationStatus.swift
//  IdentHubSDK
//

import Foundation

struct FourthlineIdentificationStatus: Decodable {

    /// Fourthline session identifier
    let identification: String

    /// Fourthline session url
    let url: String?

    /// Fourthline session status
    let identificationStatus: IdentificationStatus

    /// Identification method type: bank, idnow, fourthline
    let identificationMethod: IdentificationMethodType

    /// Identification authorization expire date
    let authExpireDate: String?

    /// Identification confirmation expire date
    let confirmExpireDate: String?

    /// Identification provider status code
    let providerStatusCode: String?

    /// Next step in identification process
    let nextStep: String?

    /// Identification documents
    var documents: [ContractDocument]? = []

    enum CodingKeys: String, CodingKey {
        case identification = "id"
        case url
        case identificationStatus = "status"
        case identificationMethod = "method"
        case authExpireDate = "authorization_expires_at"
        case confirmExpireDate = "confirmation_expires_at"
        case providerStatusCode = "provider_status_code"
        case nextStep = "next_step"
        case documents
    }
}

enum IdentificationStatus: String, Decodable {
    case success = "success"
    case failed = "failed"
    case pending = "pending"
}

enum IdentificationMethodType: String, Decodable {
    case idnow = "idnow"
    case bank = "bank"
    case fourthline = "fourthline"
}
