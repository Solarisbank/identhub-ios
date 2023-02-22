//
//  IdentificationMethod.swift
//  IdentHubSDKCore
//

import Foundation

public struct IdentificationMethod {

    /// Identification first step type. String value will be converted to the enum
    public let firstStep: IdentificationStep

    /// Identification fallback step. Used if main flow failed and used as alternative identificaiton flow
    public let fallbackStep: IdentificationStep?

    /// Amount of failure retries
    public let retries: Int

    /// Fourthline identification provider value
    public let fourthlineProvider: String?

    /// Server value coding keys
    public enum CodingKeys: String, CodingKey {
        case firstStep = "first_step"
        case fallbackStep = "fallback_step"
        case retries = "allowed_retries"
        case fourthlineProvider = "fourthline_provider"
    }
    
    public init(firstStep: IdentificationStep, fallbackStep: IdentificationStep?, retries: Int, fourthlineProvider: String?) {
        self.firstStep = firstStep
        self.fallbackStep = fallbackStep
        self.retries = retries
        self.fourthlineProvider = fourthlineProvider
    }
}

extension IdentificationMethod: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        firstStep = try container.decode(IdentificationStep.self, forKey: .firstStep)
        fallbackStep = try container.decodeIfPresent(IdentificationStep.self, forKey: .fallbackStep)
        retries = try container.decode(Int.self, forKey: .retries)
        fourthlineProvider = try container.decodeIfPresent(String.self, forKey: .fourthlineProvider)
    }
}
