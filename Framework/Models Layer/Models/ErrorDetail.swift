//
//  ErrorDetail.swift
//  IdentHubSDK
//

import Foundation

public struct ErrorDetail {

    /// List of request errors
    let errors: [ServerError]?

    /// List of full backtraces
    let backtrace: [String]?

    /// Defined fallback step if error occurs
    let fallbackStep: IdentificationStep?

    /// Defined next step if error occurs
    let nextStep: IdentificationStep?

    enum CodingKeys: String, CodingKey {
        case errors = "errors"
        case backtrace = "backtrace"
        case fallbackStep = "fallback_step"
        case nextStep = "next_step"
    }
}

extension ErrorDetail: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        errors = try container.decodeIfPresent([ServerError].self, forKey: .errors)
        backtrace = try container.decodeIfPresent([String].self, forKey: .backtrace)
        fallbackStep = try container.decodeIfPresent(IdentificationStep.self, forKey: .fallbackStep)
        nextStep = try container.decodeIfPresent(IdentificationStep.self, forKey: .nextStep)
    }
}
