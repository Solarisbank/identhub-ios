//
//  IdentificationMethod.swift
//  IdentHubSDK
//

import Foundation

struct IdentificationMethod {

    /// Identification first step type. String value will be converted to the enum
    let firstStep: IdentificationStep

    /// Identification fallback step. Used if main flow failed and used as alternative identificaiton flow
    let fallbackStep: IdentificationStep?

    /// Amount of failure retries
    let retries: Int

    /// Server value coding keys
    enum CodingKeys: String, CodingKey {
        case firstStep = "first_step"
        case fallbackStep = "fallback_step"
        case retries = "allowed_retries"
    }
}

extension IdentificationMethod: Decodable {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        firstStep = try container.decode(IdentificationStep.self, forKey: .firstStep)
        fallbackStep = try container.decodeIfPresent(IdentificationStep.self, forKey: .fallbackStep)
        retries = try container.decode(Int.self, forKey: .retries)
    }
}
