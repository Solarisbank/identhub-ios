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
