//
//  Colors.swift
//  IdentHubSDKCore
//

import UIKit

/// List of available colors.
public enum AppColor: String {
    case disableBtnText
    case disableBtnBG
    case base75
    case header
    case paragraph
    case labelText
    case primaryAccent = "primary"
    case secondaryAccent = "secondary"
    case success
    case error
    case background
    case documentInfoBackground
    case warning
}

/// Provides access to available colors
public protocol Colors {
    /// - Returns: color associated with AppColor instance
    subscript(appColor: AppColor) -> UIColor { get }
}

extension AppColor: CaseIterable {
}
