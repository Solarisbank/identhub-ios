//
//  String+Localization.swift
//  IdentHubSDKCore
//
import Foundation

public extension String {
    func localized(fromBundle bundle: Bundle) -> String {
        let languageCode = CommandLine.locale?.languageCode ?? Locale.current.languageCode ?? "en"
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
            return bundle.localizedString(forKey: self, value: self, table: nil)
        }

        return localizationBundle.localizedString(forKey: self, value: self, table: nil)
    }
}
