//
//  QESInput.swift
//  IdentHubSDKCore
//

public enum QESStep: Codable {
    case confirmAndSignDocuments
    case signDocuments
}

public struct QESInput {
    public let step: QESStep
    public let identificationUID: String
    public let mobileNumber: String?

    public init(step: QESStep, identificationUID: String, mobileNumber: String?) {
        self.step = step
        self.identificationUID = identificationUID
        self.mobileNumber = mobileNumber
    }
}
