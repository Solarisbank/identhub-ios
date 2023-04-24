//
//  Font+Extensions.swift
//  IdentHubSDKCore
//

import UIKit

public struct FontSize {
    public static let big: CGFloat = 20.0
    public static let medium: CGFloat = 16.0
    public static let small: CGFloat = 11.0
    public static let caption: CGFloat = 14.0
    
    public static let buttonTitle: CGFloat = 14.0
    public static let textField: CGFloat = 17.0
}

public extension UIFont {
    
    static func getBoldFont(_ name: String = "", size: CGFloat = UIFont.systemFontSize) -> UIFont {
        let defaultFont = UIFont.systemFont(ofSize: size, weight: .bold)
        if name.isEmpty {
            return defaultFont
        }
        return UIFont(name: name, size: size) ?? defaultFont
    }
    
    static func getFont(_ name: String = "", size: CGFloat = UIFont.systemFontSize) -> UIFont {
        let defaultFont = UIFont.systemFont(ofSize: size)
        if name.isEmpty {
            return defaultFont
        }
        return UIFont(name: name, size: size) ?? defaultFont
    }
    
    static func getItalicFont(_ name: String = "", size: CGFloat = UIFont.systemFontSize) -> UIFont {
        let defaultFont = UIFont.italicSystemFont(ofSize: size)
        if name.isEmpty {
            return defaultFont
        }
        return UIFont(name: name, size: size) ?? defaultFont
    }
}
