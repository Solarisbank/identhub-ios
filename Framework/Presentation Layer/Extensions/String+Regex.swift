//
//  String+Regex.swift
//  IdentHubSDK
//

import Foundation

internal extension String {

    /// Regex of the IBAN.
    static let IBANRegex = "^[A-Z]{2} ?[0-9]{2} ?[0-9]{4} ?[0-9]{4} ?[0-9]{4} ?[0-9]{4} ?[0-9]{2,8}$"

    /// Check if the string matches the given regex.
    ///
    /// - Parameter regex: the given regex.
    /// - Returns: if the string matches the regex.
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
