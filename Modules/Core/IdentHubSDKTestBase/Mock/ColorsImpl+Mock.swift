//
//  ColorsImpl+Mock.swift
//  IdentHubSDKTestBase
//

import IdentHubSDKCore

public extension ColorsImpl {
    static func mock() -> ColorsImpl {
        let styleColors = StyleColors(primary: "#FF00FF", primaryDark: "#FF00FF", secondary: "#00FF00")
        return ColorsImpl(styleColors: styleColors)
    }
}
