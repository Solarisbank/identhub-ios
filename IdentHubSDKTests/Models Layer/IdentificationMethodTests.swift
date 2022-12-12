//
//  IdentificationMethodTests.swift
//  IdentHubSDKTests
//

@testable import IdentHubSDK
import XCTest
import IdentHubSDKCore

final class IdentificationMethodTests: XCTestCase {
    func testRequriedModules() {
        for firstStep in IdentificationStep.allCases {
            switch firstStep {
            case .unspecified, .abort, .partnerFallback, .mobileNumber, .fourthline:
                for fallbackStep in IdentificationStep.allCases {
                    switch fallbackStep {
                    case .unspecified, .abort, .partnerFallback, .mobileNumber, .fourthline:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [])
                        
                    case .bankIDFourthline, .bankQES, .bankIDQES, .fourthlineSigning, .fourthlineQES:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.qes])
                    case .bankIBAN, .bankIDIBAN:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.bank])
                    }
                }
                
                assertIdentificationMethod(firstStep: firstStep, expectedModules: [])
            case .bankIDFourthline, .bankQES, .bankIDQES, .fourthlineSigning, .fourthlineQES:
                for fallbackStep in IdentificationStep.allCases {
                    switch fallbackStep {
                    case .bankIBAN, .bankIDIBAN:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.qes, .bank])
                    default:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.qes])
                    }
                }
                assertIdentificationMethod(firstStep: firstStep, expectedModules: [.qes])
            case .bankIBAN, .bankIDIBAN:
                assertIdentificationMethod(firstStep: firstStep, expectedModules: [.bank])
            }
        }
    }
    
    private func assertIdentificationMethod(firstStep: IdentificationStep, fallbackStep: IdentificationStep? = nil, expectedModules: Set<ModuleName>) {
        let identificationMethod = IdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, retries: 1, fourthlineProvider: nil)
        XCTAssertEqual(identificationMethod.requiredModules, expectedModules)
    }
}


