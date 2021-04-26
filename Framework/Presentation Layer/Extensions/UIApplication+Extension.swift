//
//  UIApplication+Extension.swift
//  IdentHubSDK
//

import UIKit

extension UIApplication {

    @discardableResult
    static func openAppSettings() -> Bool {
        guard
            let settingsURL = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsURL)
            else {
                return false
        }

        UIApplication.shared.open(settingsURL)
        return true
    }
}
