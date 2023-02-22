//
//  IdentificationMethodTests.swift
//  IdentHubSDKTests
//

@testable import IdentHubSDK
import XCTest
import IdentHubSDKCore
import UIKit

final class IdentificationMethodTests: XCTestCase {
    func testRequriedModules() {
        for firstStep in IdentificationStep.allCases {
            switch firstStep {
            case .unspecified, .abort, .partnerFallback, .mobileNumber:
                for fallbackStep in IdentificationStep.allCases {
                    switch fallbackStep {
                    case .unspecified, .abort, .partnerFallback, .mobileNumber:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [])
                    case .fourthline:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.fourthline])
                    case .fourthlineSigning, .fourthlineQES:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.fourthline, .qes])
                    case .bankIDFourthline:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.bank , .fourthline])
                    case .bankQES, .bankIDQES:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.bank , .qes])
                    case .bankIBAN, .bankIDIBAN:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.bank])
                    }
                }
                
                assertIdentificationMethod(firstStep: firstStep, expectedModules: [])
            case .fourthline:
                for fallbackStep in IdentificationStep.allCases {
                    switch fallbackStep {
                    case .bankIDFourthline:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.bank, .fourthline])
                    case .bankQES, .bankIDQES:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.fourthline, .bank, .qes])
                    case .bankIBAN, .bankIDIBAN:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.fourthline, .bank])
                    case .fourthlineSigning, .fourthlineQES:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.fourthline, .qes])
                    default:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.fourthline])
                    }
                }
                assertIdentificationMethod(firstStep: firstStep, expectedModules: [.fourthline])
            case .fourthlineSigning, .fourthlineQES:
                for fallbackStep in IdentificationStep.allCases {
                    switch fallbackStep {
                    case .bankIDFourthline:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.fourthline, .qes, .bank])
                    case .bankQES, .bankIDQES:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.fourthline, .bank, .qes])
                    case .bankIBAN, .bankIDIBAN:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.fourthline, .qes, .bank])
                    case .fourthlineSigning, .fourthlineQES:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.fourthline, .qes])
                    default:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.fourthline, .qes])
                    }
                }
                assertIdentificationMethod(firstStep: firstStep, expectedModules: [.fourthline, .qes])
            case .bankIDFourthline:
                for fallbackStep in IdentificationStep.allCases {
                    switch fallbackStep {
                    case .fourthlineSigning, .fourthlineQES, .bankQES, .bankIDQES:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.bank, .fourthline, .qes])
                    default:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.bank, .fourthline])
                    }
                }
                assertIdentificationMethod(firstStep: firstStep, expectedModules: [.bank , .fourthline])
            case .bankQES, .bankIDQES:
                for fallbackStep in IdentificationStep.allCases {
                    switch fallbackStep {
                    case .bankIDFourthline:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.bank , .qes , .fourthline])
                    case .fourthlineSigning, .fourthlineQES, .fourthline:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.bank , .fourthline, .qes])
                    default:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.bank, .qes])
                    }
                }
                assertIdentificationMethod(firstStep: firstStep, expectedModules: [.bank, .qes])
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
