//
//  UIView+Layout.swift
//  IdentHubSDK
//

import UIKit

internal extension UIView {

    // Add all subviews in order defined in array
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { subview in
            addSubview(subview)
        }
    }

    /// Removes all subviews from an instance of UIView.
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}
