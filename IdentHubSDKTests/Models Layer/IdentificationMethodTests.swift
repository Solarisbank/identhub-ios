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
            case .unspecified, .abort, .partnerFallback, .mobileNumber:
                for fallbackStep in IdentificationStep.allCases {
                    switch fallbackStep {
                    case .unspecified, .abort, .partnerFallback, .mobileNumber:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [])
                        
                    case .bankIBAN, .bankIDFourthline, .bankQES, .bankIDQES, .bankIDIBAN, .fourthline, .fourthlineSigning, .fourthlineQES:
                        assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.qes])
                    }
                }
                
                assertIdentificationMethod(firstStep: firstStep, expectedModules: [])
            case .bankIBAN, .bankIDFourthline, .bankQES, .bankIDQES, .bankIDIBAN, .fourthline, .fourthlineSigning, .fourthlineQES:
                for fallbackStep in IdentificationStep.allCases {
                    assertIdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, expectedModules: [.qes])
                }
                assertIdentificationMethod(firstStep: firstStep, expectedModules: [.qes])
            }
        }
    }
    
    private func assertIdentificationMethod(firstStep: IdentificationStep, fallbackStep: IdentificationStep? = nil, expectedModules: Set<ModuleName>) {
        let identificationMethod = IdentificationMethod(firstStep: firstStep, fallbackStep: fallbackStep, retries: 1, fourthlineProvider: nil)
        XCTAssertEqual(identificationMethod.requiredModules, expectedModules)
    }
}
