//
//  String+Attributes.swift
//  IdentHubSDK
//

import UIKit

internal extension String {

    /// Changes chosen text to bold with a color if provided.
    ///
    /// - Parameters:
    ///     - boldText: Text to be bold.
    ///     - color: Color of the bold text.
    func withBoldText(_ boldText: String, withColorForBoldText color: UIColor? = nil) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        let fullString = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font: font])
        let boldTextRange = fullString.mutableString.range(of: boldText)
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        if let boldTextColor = color {
            let boldTextColorAttribute = [NSAttributedString.Key.foregroundColor: boldTextColor]
            fullString.addAttributes(boldTextColorAttribute, range: boldTextRange)
        }
        fullString.addAttributes(boldFontAttribute, range: boldTextRange)
        return fullString
    }
}
