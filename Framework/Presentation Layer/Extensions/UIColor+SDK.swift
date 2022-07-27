//
//  UIColor+SDK.swift
//  IdentHubSDK
//

import UIKit
import IdentHubSDKCore

internal extension UIColor {

    /// Choose custom available color.
    static func sdkColor(_ color: AppColor) -> UIColor {
        let colors = ColorsImpl(styleColors: .obtainFromStorage())
        return colors[color]
    }
}

extension StyleColors {
    static func obtainFromStorage() -> StyleColors {
        StyleColors(
            primary: StoredKeys.StyleColor.primary.obtainFromStorage(),
            primaryDark: StoredKeys.StyleColor.primaryDark.obtainFromStorage(),
            secondary: StoredKeys.StyleColor.secondary.obtainFromStorage()
        )
    }
}

private extension StoredKeys.StyleColor {
    func obtainFromStorage() -> String? {
        SessionStorage.obtainValue(for: rawValue) as? String
    }
}
