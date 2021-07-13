//
//  BankIDStep.swift
//  IdentHubSDK
//

import Foundation

/// The list of all available actions.
enum BankIDStep: Codable {
    case startIdentification // Welcome bank id screen
    case phoneVerification // BankID phone verification
    case bankVerification(step: BankVerification) // Bank payment verification
    case signDocuments(step: SignDocuments) // Sign bank contracts
    case documentPreview(url: URL) // Signed documents preview
    case documentExport(url: URL) // Export signed documents
    case allDocumentsExport(documents: [URL]) // Export all documents
    case finishIdentification // Finish bank identification
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
        } else if let _ = try? value.decode(Bool.self, forKey: .phone) {
            self = .phoneVerification
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
        case .phoneVerification:
            try container.encode(true, forKey: .phone)
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
}

enum BankVerification: Int {
    case iban = 0 // IBAN value verifiation
    case payment = 1 // Payment verification
}

enum SignDocuments: Int {
    case confirmApplication = 0 // Confirm application document
    case sign = 1 // Sign contract documents
}
