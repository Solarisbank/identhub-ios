//
//  String+BoldAttribute.swift
//  Sample
//

import UIKit

extension String {

    /// Changes chosen text to bold with a color if provided.
    ///
    /// - Parameters:
    ///     - boldText: Text to be bold.
    ///     - color: Color of the bold text.
    func withBoldText(_ boldText: String) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        let fullString = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font: font])
        let boldTextRange = fullString.mutableString.range(of: boldText)
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        fullString.addAttributes(boldFontAttribute, range: boldTextRange)
        return fullString
    }
}
