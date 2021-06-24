//
//  ServerError.swift
//  IdentHubSDK
//

import Foundation

public struct ServerError {

    /// Error object id
    let id: String?

    /// Error object server code
    let code: String?

    /// Error title, can be used for user alert
    let title: String?

    /// Error details
    let details: String?

    /// Next step of the identification for resolving error
    let nextStep: IdentificationStep?

    enum CodingKeys: String, CodingKey {
        case id
        case code
        case title
        case details
        case nextStep = "next_step"
    }
}

extension ServerError: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        code = try container.decode(String.self, forKey: .code)
        title = try container.decode(String.self, forKey: .title)
        details = try container.decode(String.self, forKey: .details)
        nextStep = try container.decode(IdentificationStep.self, forKey: .nextStep)
    }
}
