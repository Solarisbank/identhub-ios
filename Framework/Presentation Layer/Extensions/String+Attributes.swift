//
//  String+Attributes.swift
//  IdentHubSDK
//

import UIKit

internal extension String {

    /// Changes chosen text to bold with a color if provided.
    ///
    /// - Parameters:
    ///     - arrayBoldText: Array of Text to be bold.
    ///     - color: Color of the bold text.
    func withBoldTexts(_ boldTexts: [String], withColorForBoldText color: UIColor? = nil) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        let fullString = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        
        boldTexts.forEach { text in
            let boldTextRange = fullString.mutableString.range(of: text)
            
            if let boldTextColor = color {
                let boldTextColorAttribute = [NSAttributedString.Key.foregroundColor: boldTextColor]
                fullString.addAttributes(boldTextColorAttribute, range: boldTextRange)
            }
            fullString.addAttributes(boldFontAttribute, range: boldTextRange)
        }
        return fullString
    }

    /// Returns the localized string for the key
    func localized() -> String {
        return Bundle(for: IdentHubSession.self).localizedString(forKey: self, value: self, table: nil)
    }
    
    /// Changes chosen text to mobile number with format.
    ///
    /// Returns the string with star format
    func withStarFormat() -> String {
        guard self.count > 3 else {
            return ""
        }
        let stars = String(repeating: "*", count: self.count - 3)
        return stars + "\(self.suffix(3))"
    }
    
}
