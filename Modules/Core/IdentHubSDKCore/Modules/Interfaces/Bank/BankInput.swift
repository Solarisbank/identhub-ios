//
//  BankInput.swift
//  IdentHubSDKCore
//

import Foundation

public struct BankInput {
    public let step: BankStep
    public let retriesCount: Int
    public let fallbackIdentStep: IdentificationStep?
    public let identificationUID: String
    public let identificationStep: IdentificationStep?
    
    public init(step: BankStep, retriesCount:Int, fallbackIdentStep: IdentificationStep?, identificationUID: String, identificationStep: IdentificationStep?) {
        self.step = step
        self.retriesCount = retriesCount
        self.fallbackIdentStep = fallbackIdentStep
        self.identificationUID = identificationUID
        self.identificationStep = identificationStep
    }
}

public enum BankStep: Codable, Equatable {
    case bankVerification(step: BankVerification) // Bank payment verification
    case nextStep(step: IdentificationStep) // Method called next step of the identification process
    
    enum CodingKeys: CodingKey {
        case bank
        case next
    }
    
    public init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)

        if let bank = try? value.decode(Int.self, forKey: .bank) {
            self = .bankVerification(step: BankVerification(rawValue: bank) ?? BankVerification.iban)
            return
        } else if let step = try? value.decode(IdentificationStep.self, forKey: .next) {
            self = .nextStep(step: IdentificationStep(rawValue: step.rawValue) ?? .unspecified)
            return
        }
        
        try self.init(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .bankVerification(let step):
            try container.encode(step.rawValue, forKey: .bank)
        case .nextStep(let step):
            try container.encode(step.rawValue, forKey: .next)
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.bankVerification(step: .iban), .bankVerification(step: .iban)):
            return true
        case (.bankVerification(step: .payment), .bankVerification(step: .payment)):
            return true
        default:
            return false // Return false in rest cases is fine becuase it won't be used in compare logic
        }
    }
}

public enum BankVerification: Int {
    case iban = 0 // IBAN value verifiation
    case payment = 1 // Payment verification
}
