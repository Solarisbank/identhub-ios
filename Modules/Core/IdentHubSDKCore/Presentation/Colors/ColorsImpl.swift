//
//  ColorsImpl.swift
//  IdentHubSDKCore
//
import UIKit

public typealias HexColor = String

/// Stores colors that can be customized for the SDK client
public struct StyleColors: Codable {
    public var primary: HexColor?
    public var primaryDark: HexColor?
    public var secondary: HexColor?
    
    public init(primary: HexColor? = nil, primaryDark: HexColor? = nil, secondary: HexColor? = nil) {
        self.primary = primary
        self.primaryDark = primaryDark
        self.secondary = secondary
    }
}

/// Default implemenation of Colors that allows for customization of primary and secondary colors
public struct ColorsImpl: Colors {
    private var styleColors: StyleColors
    
    public init(styleColors: StyleColors = StyleColors()) {
        self.styleColors = styleColors
    }
    
    /// - Returns: Customized color or the color from Assets bundle
    public subscript(appColor: AppColor) -> UIColor {
        switch appColor {
        case .primaryAccent, .secondaryAccent:
            return customizedColor(for: appColor) ?? appColor.color
        default:
            return appColor.color
        }
    }
    
    private func customizedColor(for appColor: AppColor) -> UIColor? {
        switch appColor {
        case .primaryAccent:
            
            if #available(iOS 13.0, *) {
                return UIColor { traitCollection in
                    switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return styleColors.primaryDark?.color() ?? appColor.color
                    default:
                        return styleColors.primary?.color() ?? appColor.color
                    }
                }
            } else {
                // Fallback on earlier versions
                // Return light mode color as dark mode is not supported for iOS < 13.0
                return styleColors.primary?.color()
            }
        case .secondaryAccent:
            return styleColors.secondary?.color()
        default:
            return nil
        }
    }
}

extension AppColor {
    var color: UIColor {
        guard let color = UIColor.fromAssets(named: rawValue) else {
            fatalError("Color \(rawValue) not found in the Assets bundle")
        }
        return color
    }
}

private extension HexColor {
    func color() -> UIColor? {
        UIColor(hex: self)
    }
}
