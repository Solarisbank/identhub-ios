//
//  IdentificationMethod.swift
//  IdentHubSDK
//

import Foundation

struct IdentificationMethod {

    /// Identification first step type. String value will be converted to the enum
    let firstStep: IdentificationStep

    /// Server value coding keys
    enum CodingKeys: String, CodingKey {
        case firstStep = "first_step"
    }
}

extension IdentificationMethod: Decodable {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        firstStep = try container.decode(IdentificationStep.self, forKey: .firstStep)
    }
}
