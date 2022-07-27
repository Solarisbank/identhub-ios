//
//  ImageTests.swift
//  IdentHubSDKCoreTests
//

import XCTest
@testable import IdentHubSDKCore

class ImageTests: XCTestCase {

    func testImageAvailability() {
        for image in Image.Shared.allCases {
            XCTAssertNotNil(image.image())
        }
    }
}
