//
//  String+Localization.swift
//  IdentHubSDKCore
//
import Foundation

internal extension String {
    /// Returns the localized string for the key
    func localized() -> String {
        localized(fromBundle: Bundle.current)
    }
}
