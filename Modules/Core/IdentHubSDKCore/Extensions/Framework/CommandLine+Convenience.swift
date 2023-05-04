//
//  CommandLine+Convenience.swift
//  IdentHubSDKCore
//
import Foundation

public extension CommandLine {
    static var locale: Locale? {
        if let index = arguments.firstIndex(of: "-AppleLocale")?.advanced(by: 1) {
            if index < arguments.endIndex {
                return Locale(identifier: arguments[index])
            }
        }
        return nil
    }
}

public extension Locale {
    static var preferredLanguageCode: String {
        guard let preferredLanguage = preferredLanguages.first,
              let code = Locale(identifier: preferredLanguage).languageCode else {
            return Locale.current.languageCode ?? "en"
        }
        return code
    }
    
    static var preferredLanguageCodes: [String] {
        return Locale.preferredLanguages.compactMap({Locale(identifier: $0).languageCode})
    }
}
