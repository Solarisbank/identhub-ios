//
//  IdentificationMethod.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

protocol Modularizable {
    var requiredModules: Set<ModuleName> { get }
}

extension IdentificationMethod: Modularizable {
    var requiredModules: Set<ModuleName> {
        firstStep.requiredModules.union(fallbackStep?.requiredModules ?? [])
    }
}

extension IdentificationStep: Modularizable {
    var requiredModules: Set<ModuleName> {
        switch self {
        case .unspecified, .abort, .partnerFallback, .mobileNumber:
            return []
        case .fourthlineSigning, .fourthlineQES:
            return [.fourthline, .qes]
        case .fourthline:
            return [.fourthline]
        case .bankIDFourthline:
            return [.bank , .fourthline]
        case .bankQES, .bankIDQES :
            return [.bank, .qes]
        case .bankIBAN, .bankIDIBAN:
            return [.bank]
        }
    }
}
