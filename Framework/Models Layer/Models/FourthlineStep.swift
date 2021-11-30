//
//  FourthlineSteps.swift
//  IdentHubSDK
//

import Foundation
import FourthlineCore

/// The list of all available actions.
enum FourthlineStep: Codable, Equatable {
    case welcome // Welcome screen with all instructions
    case selfie // Make a selfie step
    case fetchData // Fetch person data from server and device
    case documentPicker // Present document picker step
    case documentScanner(type: DocumentType) // Present document scanner for document with type: passport, idCard, etc.
    case documentInfo // Verify and confirm scanned document detail
    case location // Fetch device location coordinates
    case upload // Upload collected data to the server
    case confirmation // Confirm or fail user identification request
    case result(result: FourthlineIdentificationStatus) // Result screen with result status
    case quit // Quit from identification process
    case complete(result: FourthlineIdentificationStatus) // Close identification screen with passing ident result
    case nextStep(step: IdentificationStep) // Method called next step of the identification process
    case abort // Method called when identification method should be closed
    case close(error: APIError) // Abort identification process with error reason

    enum CodingKeys: CodingKey {

        case welcome
        case selfie
        case fetchData
        case documentPicker
        case documentScannerType
        case documentInfo
        case location
        case upload
        case confirmation
        case resultStatus
        case quit
        case complete
        case next
        case abort
        case close
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        if let _ = try? values.decode(Bool.self, forKey: .welcome) {
            self = .welcome
            return
        } else if let _ = try? values.decode(Bool.self, forKey: .selfie) {
            self = .selfie
            return
        } else if let _ = try? values.decode(Bool.self, forKey: .fetchData) {
            self = .fetchData
            return
        } else if let _ = try? values.decode(Bool.self, forKey: .documentPicker) {
            self = .documentPicker
            return
        } else if let type = try? values.decode(Int.self, forKey: .documentScannerType) {
            self = .documentScanner(type: DocumentType(rawValue: type) ?? .passport)
            return
        } else if let _ = try? values.decode(Bool.self, forKey: .documentInfo) {
            self = .documentInfo
            return
        } else if let _ = try? values.decode(Bool.self, forKey: .location) {
            self = .location
            return
        } else if let _ = try? values.decode(Bool.self, forKey: .upload) {
            self = .upload
            return
        } else if let _ = try? values.decode(Bool.self, forKey: .confirmation) {
            self = .confirmation
            return
        } else if let result = try? values.decode(FourthlineIdentificationStatus.self, forKey: .resultStatus) {
            self = .result(result: result)
            return
        } else if let _ = try? values.decode(Bool.self, forKey: .quit) {
            self = .quit
            return
        } else if let step = try? values.decode(IdentificationStep.self, forKey: .next) {
            self = .nextStep(step: IdentificationStep(rawValue: step.rawValue) ?? .unspecified)
            return
        } else {
            self = .welcome
            print("\(values) encoded with error")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .welcome:
            try container.encode(true, forKey: .welcome)
        case .selfie:
            try container.encode(true, forKey: .selfie)
        case .fetchData:
            try container.encode(true, forKey: .fetchData)
        case .documentPicker:
            try container.encode(true, forKey: .documentPicker)
        case .documentScanner(let type):
            try container.encode(type.rawValue, forKey: .documentScannerType)
        case .documentInfo:
            try container.encode(true, forKey: .documentInfo)
        case .location:
            try container.encode(true, forKey: .location)
        case .upload:
            try container.encode(true, forKey: .upload)
        case .confirmation:
            try container.encode(true, forKey: .confirmation)
        case .result(let result):
            try container.encode(result, forKey: .resultStatus)
        case .quit,
             .complete,
             .abort,
             .close(_):
            try container.encode(true, forKey: .quit)
        case .nextStep(let step):
            try container.encode(step.rawValue, forKey: .next)
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.confirmation, .confirmation),
             (.fetchData, .fetchData),
             (.abort, .abort):
            return true
        default:
            return false
        }
    }
}
