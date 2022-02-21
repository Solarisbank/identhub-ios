//
//  String+Regex.swift
//  IdentHubSDK
//

import Foundation

internal extension String {

    /// Regex of the IBAN.
    static let IBANRegex = "^[A-Z]{2} ?[0-9]{2} ?[0-9]{4} ?[0-9]{4} ?[0-9]{4} ?[0-9]{4} ?[0-9]{2,8}$"
    
    /// Regex of the street number in address
    static let streetNumberRegex = "-?\\d+"
    
    /// Regex of the street number suffix in address
    static let streetNumberSuffixRegex = "-?[a-zA-Z]+"

    /// Check if the string matches the given regex.
    ///
    /// - Parameter regex: the given regex.
    /// - Returns: if the string matches the regex.
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    /// Split string to the collection by regular expression matches
    /// - Parameter regex: regular expression pattern
    /// - Returns: array with matched strings
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
