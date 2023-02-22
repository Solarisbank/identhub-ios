//
//  CoreInput.swift
//  IdentHubSDKCore
//

import Foundation

public enum CoreStep: Codable {
    case initateFlow
    case termsConditions
    case phoneVerification
}

public struct CoreInput {
    public let step: CoreStep
    public var sessionToken: String?

    public init(step: CoreStep, sessionToken: String) {
        self.step = step
        self.sessionToken = sessionToken
    }
}

public enum CoreOutput: Equatable {
    public static func == (lhs: CoreOutput, rhs: CoreOutput) -> Bool {
        return false
    }
    
    case startIdentification(_ session: StorageSessionInfoProvider, info: IdentificationInfo? = nil)
    case fourthline(_ step: FourthlineStep, _ fourthlineProvider: String? = nil)
    case phoneVerificationConfirm
    case abort
}
