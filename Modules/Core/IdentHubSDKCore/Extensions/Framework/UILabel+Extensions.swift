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
}

public extension UILabel {
    
    /// Method used to set UILabel style
    @discardableResult
    func setLabelStyle(_ style: UILabelStyle) -> UILabel {
        let colors: Colors = ColorsImpl() //Only SDK colors
        
        switch style {
        case .title:
            self.font = UIFont.getBoldFont(size: FontSize.big)
            self.textColor = colors[.black75]
        case .subtitle:
            self.font = UIFont.getFont(size: FontSize.medium)
            self.textColor = colors[.black50]
        case .caption:
            self.font = UIFont.getFont(size: FontSize.caption)
            self.textColor = colors[.base50]
        case .error:
            self.font = UIFont.getFont(size: FontSize.caption)
            self.textColor = colors[.error]
        case .buttonTitle:
            self.font = UIFont.getBoldFont(size: FontSize.buttonTitle)
        }
        
        return self
    }

}

public extension UITextView {
    
    @discardableResult
    func setTextViewStyle() -> UITextView {
        let colors: Colors = ColorsImpl() //Only SDK colors
        
        self.font = UIFont.getFont(size: FontSize.caption)
        self.textColor = colors[.base50]
        return self
    }
    
}

public extension UIButton {
    
    @discardableResult
    func setBtnTitleStyle() -> UIButton {
        let colors: Colors = ColorsImpl() //Only SDK colors
        
        self.titleLabel?.font = UIFont.getFont(size: FontSize.buttonTitle)
        self.titleLabel?.textColor = colors[.base100]
        return self
    }
}
