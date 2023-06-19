//
//  String+Localization.swift
//  IdentHubSDKCore
//
import Foundation

public extension String {
    func localized(fromBundle bundle: Bundle) -> String {
        let languageCode = CommandLine.locale?.languageCode ?? Locale.preferredLanguageCode
        return localized(fromBundle: bundle, forLanguageCode: languageCode)
    }
}

extension String {
    /// Returns the localized string for the key
    func localized() -> String {
        return localized(fromBundle: Bundle.current)
    }

    func localized(fromBundle bundle: Bundle, forLanguageCode languageCode: String) -> String {
        guard let path = bundle.path(forResource: languageCode, ofType: "lproj"),
              let localizationBundle = Bundle(path: path) else {
                var localized = NSLocalizedString(self, tableName: "InitialString", bundle: bundle, value: self, comment: "")
                if localized == self {
                    localized = bundle.localizedString(forKey: self, value: self, table: nil)
                }
             return localized
        }

        var localized = NSLocalizedString(self, tableName: "InitialString", bundle: localizationBundle, value: self, comment: "")
         if localized == self {
           localized = localizationBundle.localizedString(forKey: self, value: self, table: nil)
         }
         return localized
    }
}
