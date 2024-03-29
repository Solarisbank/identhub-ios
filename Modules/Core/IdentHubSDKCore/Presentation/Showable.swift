//
//  Showable.swift
//  Core
//

import UIKit

public protocol Showable: AnyObject {

    func toShowable() -> UIViewController
}

extension UIViewController: Showable {

    public func toShowable() -> UIViewController {
        return self
    }
}

public extension Showable {
    func push(on presenter: Presenter, animated: Bool = true, completion: (() -> Void)? = nil) {
        presenter.push(self, animated: animated, completion: completion)
    }
    
    func present(on presenter: Presenter, animated: Bool = true) {
        presenter.present(self, animated: animated)
    }
    
    func pop(on presenter: Presenter, animated: Bool = true) {
        presenter.pop(self, animated: animated)
    }
}
