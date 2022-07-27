//
//  ColorsImplTests.swift
//  IdentHubSDKCoreTests
//

import XCTest
@testable import IdentHubSDKCore

class ColorsImplTests: XCTestCase {
    func testColorsAvailability() {
        let sut = ColorsImpl()
        
        for color in AppColor.allCases {
            XCTAssertNotNil(sut[color])
        }
    }
    
    func testColorsCustomization() {
        var expectedPrimaryAccent = UIColor.red.rgba
        if #available(iOS 13.0, *) {
          if UITraitCollection.current.userInterfaceStyle == .dark {
            expectedPrimaryAccent = UIColor.green.rgba
          }
        }
        let sut = ColorsImpl(styleColors: .init(primary: "#FF0000", primaryDark: "#00FF00", secondary: "#0000FF"))
        XCTAssertEqual(sut[.primaryAccent].rgba, expectedPrimaryAccent)
        XCTAssertEqual(sut[.secondaryAccent].rgba, UIColor.blue.rgba)
        XCTAssertEqual(sut[.background].rgba, AppColor.background.color.rgba)
    }
}

private extension UIColor {
    struct RGBA: Equatable {
        public let red: CGFloat
        public let green: CGFloat
        public let blue: CGFloat
        public let alpha: CGFloat
    }

    var rgba: RGBA? {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        return RGBA(red: red, green: green, blue: blue, alpha: alpha)
    }
}
