//
//  ErrorDetail.swift
//  IdentHubSDKCore
//

import Foundation

public struct ErrorDetail: Equatable {

    /// List of request errors
    public let errors: [ServerError]?

    /// List of full backtraces
    public let backtrace: [String]?

    /// Defined fallback step if error occurs
    public let fallbackStep: IdentificationStep?

    /// Defined next step if error occurs
    public let nextStep: IdentificationStep?

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
