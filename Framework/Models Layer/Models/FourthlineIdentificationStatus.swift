//
//  FourthlineIdentificationStatus.swift
//  IdentHubSDK
//

import Foundation

struct FourthlineIdentificationStatus: Codable {

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

extension FourthlineIdentificationStatus {

    init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)

        self.identification = try data.decode(String.self, forKey: .identification)
        self.url = try data.decode(String.self, forKey: .url)
        self.identificationStatus = try data.decode(IdentificationStatus.self, forKey: .identificationStatus)
        self.identificationMethod = try data.decode(IdentificationMethodType.self, forKey: .identificationMethod)
        self.authExpireDate = try data.decode(String.self, forKey: .authExpireDate)
        self.confirmExpireDate = try data.decode(String.self, forKey: .confirmExpireDate)
        self.providerStatusCode = try data.decode(String.self, forKey: .providerStatusCode)
        self.nextStep = try data.decode(String.self, forKey: .nextStep)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identification, forKey: .identification)
        try container.encode(url, forKey: .url)
        try container.encode(identificationStatus.self.rawValue, forKey: .identificationStatus)
        try container.encode(identificationMethod.self.rawValue, forKey: .identificationMethod)
        try container.encode(authExpireDate, forKey: .authExpireDate)
        try container.encode(confirmExpireDate, forKey: .confirmExpireDate)
        try container.encode(providerStatusCode, forKey: .providerStatusCode)
        try container.encode(nextStep, forKey: .nextStep)
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
