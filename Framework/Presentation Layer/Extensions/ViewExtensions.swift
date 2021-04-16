//
//  UIExtensions.swift
//  IdentHubSDK
//

import UIKit

extension UIView {

    @discardableResult
    class func fromNib() -> Self {
        let bundle = Bundle(for: Self.self)
        let nibName = String(describing: Self.self)
        let views = bundle.loadNibNamed(nibName, owner: self, options: nil)
        guard let viewFromNib = views?.first as? Self else {
            fatalError("Could not load view from \(nibName)")
        }
        return viewFromNib
    }
}

extension UIViewController {

    func add(child: UIViewController) {
        addChild(child)
        child.view.frame = view.bounds
        view.addSubview(child.view)
    }
}
