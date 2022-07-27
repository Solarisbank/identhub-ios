//
//  UIApplication+Extension.swift
//  IdentHubSDKCore
//

import UIKit

public extension UIApplication {
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

extension UIViewController {
    var topViewController: UIViewController {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topViewController ?? self
        } else if let presentedViewController = self.presentedViewController {
            return presentedViewController.topViewController
        } else {
            return self
        }
    }
}
