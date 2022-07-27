//
//  Colors.swift
//  IdentHubSDKCore
//

import UIKit

/// List of available colors.
public enum AppColor: String {
    case base100
    case base75
    case base50
    case base25
    case base10
    case base05
    case black100
    case black75
    case black50
    case black25
    case black10
    case black05
    case black0
    case primaryAccent = "primary"
    case primaryAccentLighten = "primary_lighten"
    case primaryAccentDarken = "primary_darken"
    case primaryTint = "primary_tint"
    case secondaryAccent = "secondary"
    case secondaryAccentLighten = "secondary_lighten"
    case secondaryAccentDarken = "secondary_darken"
    case secondaryTint = "secondary_tint"
    case success
    case successLighten = "success_lighten"
    case successDarken = "success_darken"
    case error
    case errorLighten = "error_lighten"
    case errorDarken = "error_darken"
    case errorTint = "error_tint"
    case neutralWhite = "neutral_white"
    case background
}

/// Provides access to available colors
public protocol Colors {
    /// - Returns: color associated with AppColor instance
    subscript(appColor: AppColor) -> UIColor { get }
}

extension AppColor: CaseIterable {
}
