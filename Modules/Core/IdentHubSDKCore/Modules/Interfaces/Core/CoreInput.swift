//
//  CoreInput.swift
//  IdentHubSDKCore
//

import Foundation

public enum CoreStep: Codable {
    case phoneVerification
}

public struct CoreInput {
    public let step: CoreStep
    public let identificationUID: String
    public let identificationStep: IdentificationStep?

    public init(step: CoreStep, identificationUID: String, identificationStep: IdentificationStep?) {
        self.step = step
        self.identificationUID = identificationUID
        self.identificationStep = identificationStep
    }
}

public enum CoreOutput: Equatable {
    case phoneVerificationConfirm
    case abort
}
