//
//  BankIDStep.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

/// The list of all available actions.
enum BankIDStep: Codable, Equatable {
    case startIdentification // Welcome bank id screen
    case bankVerification(step: BankVerification) // Bank payment verification
    case signDocuments(step: SignDocuments) // Sign bank contracts
    case finishIdentification // Finish bank identification
    case notifyHandlers // Case for notifying all handlers about ident results
    case nextStep(step: IdentificationStep) // Method called next step of the identification process
    case pop // return back to the previous bank id step
    case quit // Quit from identificaton process
    case close // Close identification screen

    enum CodingKeys: CodingKey {
        case start
        case phone
        case bank
        case signDocument
        case documentPreview
        case documentExport
        case allDocumentsExport
        case finish
        case notify
        case next
        case pop
        case quit
        case close
    }

    init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)

        if let _ = try? value.decode(Bool.self, forKey: .start) {
            self = .startIdentification
            return
        } else if let bank = try? value.decode(Int.self, forKey: .bank) {
            self = .bankVerification(step: BankVerification(rawValue: bank) ?? BankVerification.iban)
            return
        } else if let sign = try? value.decode(Int.self, forKey: .signDocument) {
            self = .signDocuments(step: SignDocuments(rawValue: sign) ?? SignDocuments.confirmApplication)
            return
        } else if let step = try? value.decode(IdentificationStep.self, forKey: .next) {
            self = .nextStep(step: IdentificationStep(rawValue: step.rawValue) ?? .unspecified)
            return
        } else {
            self = .finishIdentification
            return
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .startIdentification:
            try container.encode(true, forKey: .start)
        case .bankVerification(let step):
            try container.encode(step.rawValue, forKey: .bank)
        case .signDocuments(let step):
            try container.encode(step.rawValue, forKey: .signDocument)
        case .finishIdentification:
            try container.encode(true, forKey: .finish)
        case .nextStep(let step):
            try container.encode(step.rawValue, forKey: .next)
        default:
            try container.encode(true, forKey: .finish)
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.bankVerification(step: .iban), .bankVerification(step: .iban)):
            return true
        case (.bankVerification(step: .payment), .bankVerification(step: .payment)):
            return true
        case (.signDocuments(step: .confirmApplication), .signDocuments(step: .confirmApplication)):
            return true
        case (.signDocuments(step: .sign), .signDocuments(step: .sign)):
            return true
        default:
            return false // Return false in rest cases is fine becuase it won't be used in compare logic
        }
    }
}

enum BankVerification: Int {
    case iban = 0 // IBAN value verifiation
    case payment = 1 // Payment verification
}

enum SignDocuments: Int {
    case confirmApplication = 0 // Confirm application document
    case sign = 1 // Sign contract documents
}
