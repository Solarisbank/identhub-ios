//
//  BankIDStep.swift
//  IdentHubSDK
//

import Foundation

/// The list of all available actions.
enum CoreScreensStep: Codable, Equatable {
    case phoneVerification // Welcome bank id screen
    case quit // Quit from identificaton process
    case close // Close identification screen
}
