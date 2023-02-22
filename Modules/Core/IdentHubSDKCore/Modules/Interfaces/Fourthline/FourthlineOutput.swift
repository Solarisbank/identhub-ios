//
//  FourthlineOutput.swift
//  IdentHubSDKCore
//

/// Output from the fourthline coordinator.
public enum FourthlineOutput: Equatable {
    public static func == (lhs: FourthlineOutput, rhs: FourthlineOutput) -> Bool {
        return true
    }
    
    case complete(result: FourthlineIdentificationStatus)
    case nextStep(step: IdentificationStep, _ identUID: String? = nil) // Method called next step of the identification process
    case abort
    case close
}
