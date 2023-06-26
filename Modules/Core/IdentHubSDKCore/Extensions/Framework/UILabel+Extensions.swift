//
//  UILabel+Extensions.swift
//  IdentHubSDKCore
//

import UIKit

public enum UILabelStyle {
    case title
    case subtitle
    case caption
    case error
    case buttonTitle
    case custom(font: UIFont, color:UIColor)
}

public extension UILabel {
    
    /// Method used to set UILabel style
    @discardableResult
    func setLabelStyle(_ style: UILabelStyle) -> UILabel {
        let colors: Colors = ColorsImpl() //Only SDK colors
        
        switch style {
        case .title:
            self.font = UIFont.getBoldFont(size: FontSize.big)
            self.textColor = colors[.header]
        case .subtitle:
            self.font = UIFont.getFont(size: FontSize.medium)
            self.textColor = colors[.paragraph]
        case .caption:
            self.font = UIFont.getFont(size: FontSize.caption)
            self.textColor = colors[.paragraph]
        case .error:
            self.font = UIFont.getFont(size: FontSize.caption)
            self.textColor = colors[.error]
        case .buttonTitle:
            self.font = UIFont.getBoldFont(size: FontSize.buttonTitle)
        case .custom(font: let font, color: let color):
            self.font = font
            self.textColor = color
        }
        
        return self
    }

}

public extension UITextView {
    
    @discardableResult
    func setTextViewStyle() -> UITextView {
        let colors: Colors = ColorsImpl() //Only SDK colors
        
        self.font = UIFont.getFont(size: FontSize.caption)
        self.textColor = colors[.paragraph]
        return self
    }
    
}

public extension UIButton {
    
    @discardableResult
    func setBtnTitleStyle() -> UIButton {
        let colors: Colors = ColorsImpl() //Only SDK colors
        
        self.titleLabel?.font = UIFont.getBoldFont(size: FontSize.buttonTitle)
        self.titleLabel?.textColor = colors[.disableBtnText]
        return self
    }
}
