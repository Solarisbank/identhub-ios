//
//  QESOutput.swift
//  IdentHubSDKCore
//

/// Output from the QES coordinator.
public enum QESOutput: Equatable {
    case identificationConfirmed(identificationToken: String)
    case abort
}
