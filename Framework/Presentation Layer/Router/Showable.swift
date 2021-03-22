//
//  Showable.swift
//  IdentHubSDK
//

import UIKit

protocol Showable {

    func toShowable() -> UIViewController
}

extension UIViewController: Showable {

    func toShowable() -> UIViewController {
        return self
    }
}
