//
//  BankOutput.swift
//  IdentHubSDKCore
//

/// Output from the Bank coordinator.
public enum BankOutput: Equatable {
    case performQES(identID: String)
    case nextStep(step: IdentificationStep, _ identUID: String? = nil) // Method called next step of the identification process
    case failure(APIError)
    case abort
}
