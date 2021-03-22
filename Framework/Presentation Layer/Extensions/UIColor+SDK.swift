//
//  UIColor+SDK.swift
//  IdentHubSDK
//

import UIKit

internal extension UIColor {

    /// List of available colors.
    enum AppColor {
        case base100
        case base75
        case base50
        case base25
        case base10
        case base05
        case black75
        case black50
        case black25
        case black10
        case black05
        case primaryAccent
        case secondaryAccent
        case secondaryTint
        case success
        case error
        case errorTint
    }

    /// Choose custom available color.
    static func sdkColor(_ color: AppColor) -> UIColor {
        switch color {
        case .base100:
            return #colorLiteral(red: 0.05882352941, green: 0.09803921569, blue: 0.1490196078, alpha: 1)
        case .base75:
            return #colorLiteral(red: 0.2549019608, green: 0.3019607843, blue: 0.3647058824, alpha: 1)
        case .base50:
            return #colorLiteral(red: 0.4941176471, green: 0.5294117647, blue: 0.5803921569, alpha: 1)
        case .base25:
            return #colorLiteral(red: 0.7725490196, green: 0.7921568627, blue: 0.8196078431, alpha: 1)
        case .base10:
            return #colorLiteral(red: 0.9137254902, green: 0.9294117647, blue: 0.9490196078, alpha: 1)
        case .base05:
            return #colorLiteral(red: 0.9803921569, green: 0.9843137255, blue: 0.9882352941, alpha: 1)
        case .black75:
            return #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
        case .black50:
            return #colorLiteral(red: 0.4980392157, green: 0.4980392157, blue: 0.4980392157, alpha: 1)
        case .black25:
            return #colorLiteral(red: 0.7490196078, green: 0.7490196078, blue: 0.7490196078, alpha: 1)
        case .black10:
            return #colorLiteral(red: 0.9019607843, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        case .black05:
            return #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        case .primaryAccent:
            return #colorLiteral(red: 1, green: 0.3921568627, blue: 0.1960784314, alpha: 1)
        case .secondaryAccent:
            return #colorLiteral(red: 0.1960784314, green: 0.5176470588, blue: 1, alpha: 1)
        case .secondaryTint:
            return #colorLiteral(red: 0.9490196078, green: 0.968627451, blue: 1, alpha: 1)
        case .success:
            return #colorLiteral(red: 0.03529411765, green: 0.6666666667, blue: 0.4039215686, alpha: 1)
        case .error:
            return #colorLiteral(red: 0.8862745098, green: 0.2117647059, blue: 0.2117647059, alpha: 1)
        case .errorTint:
            return #colorLiteral(red: 1, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        }
    }
}
