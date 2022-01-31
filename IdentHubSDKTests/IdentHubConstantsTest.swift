//
//  IdentHubConstantsTest.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK


class IdentHubConstantsTest: XCTestCase {

    func testDecodeIdentificationStep() throws {
        
        // test some of the uniquely defined cases (not all possibilities)
        let mobileNumberIdentificationStep = try JSONDecoder().decode(IdentificationStep.self, from: "\"mobile_number\"".data(using: .utf8)!)
        XCTAssertEqual(mobileNumberIdentificationStep, .mobileNumber)
        let partnerFallbackIdentificationStep = try JSONDecoder().decode(IdentificationStep.self, from: "\"partner_fallback\"".data(using: .utf8)!)
        XCTAssertEqual(partnerFallbackIdentificationStep, .partnerFallback)
        let abortIdentificationStep = try JSONDecoder().decode(IdentificationStep.self, from: "\"abort\"".data(using: .utf8)!)
        XCTAssertEqual(abortIdentificationStep, .abort)
        
        // test undefined case
        let unknownIdentificationStep = try JSONDecoder().decode(IdentificationStep.self, from: "\"some_unknown_response\"".data(using: .utf8)!)
        XCTAssertEqual(unknownIdentificationStep, .unspecified)
    }

}
