//
//  UIColor+SDK.swift
//  IdentHubSDK
//

import UIKit

internal extension UIColor {

    /// Hex color initializer
    convenience init?(hex: String) {
        let hexString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let a: Int
        if hex.count >= 8 {
            a = Int(color >> 24) & mask
        } else {
            a = 255
        }
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        let alpha = CGFloat(a) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// List of available colors.
    enum AppColor {
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
        case primaryAccent
        case primaryAccentLighten
        case primaryAccentDarken
        case primaryTint
        case secondaryAccent
        case secondaryAccentLighten
        case secondaryAccentDarken
        case secondaryTint
        case success
        case successLighten
        case successDarken
        case error
        case errorLighten
        case errorDarken
        case errorTint
        case neutralWhite
        case background
    }

    /// Choose custom available color.
    static func sdkColor(_ color: AppColor) -> UIColor {
        if let customizedColor = customizedColor(color) {
            return customizedColor
        }

        switch color {
        case .base100:
            return assetsColor(by: "base100") ?? #colorLiteral(red: 0.05882352941, green: 0.09803921569, blue: 0.1490196078, alpha: 1)
        case .base75:
            return assetsColor(by: "base75") ?? #colorLiteral(red: 0.2549019608, green: 0.3019607843, blue: 0.3647058824, alpha: 1)
        case .base50:
            return assetsColor(by: "base50") ?? #colorLiteral(red: 0.4941176471, green: 0.5294117647, blue: 0.5803921569, alpha: 1)
        case .base25:
            return assetsColor(by: "base25") ?? #colorLiteral(red: 0.7725490196, green: 0.7921568627, blue: 0.8196078431, alpha: 1)
        case .base10:
            return assetsColor(by: "base10") ?? #colorLiteral(red: 0.9137254902, green: 0.9294117647, blue: 0.9490196078, alpha: 1)
        case .base05:
            return assetsColor(by: "base05") ?? #colorLiteral(red: 0.9803921569, green: 0.9843137255, blue: 0.9882352941, alpha: 1)
        case .black100:
            return assetsColor(by: "black100") ?? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .black75:
            return assetsColor(by: "black75") ?? #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
        case .black50:
            return assetsColor(by: "black50") ?? #colorLiteral(red: 0.4980392157, green: 0.4980392157, blue: 0.4980392157, alpha: 1)
        case .black25:
            return assetsColor(by: "black25") ?? #colorLiteral(red: 0.7490196078, green: 0.7490196078, blue: 0.7490196078, alpha: 1)
        case .black10:
            return assetsColor(by: "black10") ?? #colorLiteral(red: 0.9019607843, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        case .black05:
            return assetsColor(by: "black05") ?? #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        case .black0:
            return assetsColor(by: "black0") ?? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .primaryAccent:
            return assetsColor(by: "primary") ?? #colorLiteral(red: 1, green: 0.3921568627, blue: 0.1960784314, alpha: 1)
        case .primaryAccentLighten:
            return assetsColor(by: "primary_lighten") ?? #colorLiteral(red: 1, green: 0.3921568627, blue: 0.1960784314, alpha: 1)
        case .primaryAccentDarken:
            return assetsColor(by: "primary_darken") ?? #colorLiteral(red: 0.798679769, green: 0.3169504106, blue: 0.1685302556, alpha: 1)
        case .primaryTint:
            return assetsColor(by: "primary_tint") ?? #colorLiteral(red: 1, green: 0.9607843137, blue: 0.9490196078, alpha: 1)
        case .secondaryAccent:
            return assetsColor(by: "secondary") ?? #colorLiteral(red: 0.1960784314, green: 0.5176470588, blue: 1, alpha: 1)
        case .secondaryAccentLighten:
            return assetsColor(by: "secondary_lighten") ?? #colorLiteral(red: 0.3490196078, green: 0.6117647059, blue: 1, alpha: 1)
        case .secondaryAccentDarken:
            return assetsColor(by: "secondary_darken") ?? #colorLiteral(red: 0.1607843137, green: 0.4156862745, blue: 0.8, alpha: 1)
        case .secondaryTint:
            return assetsColor(by: "secondary_tint") ?? #colorLiteral(red: 0.9490196078, green: 0.968627451, blue: 1, alpha: 1)
        case .success:
            return assetsColor(by: "success") ?? #colorLiteral(red: 0.03529411765, green: 0.6666666667, blue: 0.4039215686, alpha: 1)
        case .successLighten:
            return assetsColor(by: "success_lighten") ?? #colorLiteral(red: 0.03529411765, green: 0.6666666667, blue: 0.4039215686, alpha: 1)
        case .successDarken:
            return assetsColor(by: "success_darken") ?? #colorLiteral(red: 0.0431372549, green: 0.8117647059, blue: 0.4901960784, alpha: 1)
        case .error:
            return assetsColor(by: "error") ?? #colorLiteral(red: 0.8862745098, green: 0.2117647059, blue: 0.2117647059, alpha: 1)
        case .errorLighten:
            return assetsColor(by: "error_lighten") ?? #colorLiteral(red: 1, green: 0.3098039216, blue: 0.3098039216, alpha: 1)
        case .errorDarken:
            return assetsColor(by: "error_darken") ?? #colorLiteral(red: 0.02745098039, green: 0.5098039216, blue: 0.3098039216, alpha: 1)
        case .errorTint:
            return assetsColor(by: "error_tint") ?? #colorLiteral(red: 1, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        case .neutralWhite:
            return assetsColor(by: "neutral_white") ?? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .background:
            return assetsColor(by: "background") ?? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }

    static func assetsColor(by name: String) -> UIColor? {
        return UIColor(named: name, in: Bundle.current, compatibleWith: nil)
    }

    static func customizedColor(_ color: AppColor) -> UIColor? {
        let darkMode: Bool

        if #available(iOS 13.0, *) {
            darkMode = UITraitCollection.current.userInterfaceStyle == .dark
        } else {
            darkMode = false
        }

        switch color {
        case .primaryAccent:
            if darkMode {
                return obtainCustomizedColor(color: .primaryDark)
            } else {
                return obtainCustomizedColor(color: .primary)
            }
        case .secondaryAccent:
            return obtainCustomizedColor(color: .secondary)
        default:
            return nil
        }
    }

    private static func obtainCustomizedColor(color: StoredKeys.StyleColor) -> UIColor? {
        if let colorHex = SessionStorage.obtainValue(for: color.rawValue) as? String {
            return UIColor(hex: colorHex)
        } else {
            return nil
        }
    }
}
