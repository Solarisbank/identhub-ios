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
            print("Could not load view from \(nibName)")
            return UIView() as! Self
        }
        return viewFromNib
    }

    func remake(constraint: NSLayoutConstraint, multiplier: CGFloat) -> NSLayoutConstraint {
        let newConstraint = constraint.constraintWithMultiplier(multiplier)
        constraint.isActive = false
        addConstraint(newConstraint)
        return newConstraint
    }
}

extension NSLayoutConstraint {

    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

extension UIViewController {

    func add(child: UIViewController) {
        addChild(child)
        child.view.frame = view.bounds
        view.addSubview(child.view)
    }
}
