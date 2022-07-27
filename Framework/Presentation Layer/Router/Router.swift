//
//  Router.swift
//  IdentHubSDK
//

import UIKit
import IdentHubSDKCore

/// App navigation protocol
protocol Router: Presenter {

    var navigationController: UINavigationController { get }
    var rootViewController: UIViewController? { get }

    // Base screens navigation methods
    func present(_ module: Showable, animated: Bool)
    func dismissModule(animated: Bool, completion: (() -> Void)?)
    func push(_ module: Showable, animated: Bool, completion: (() -> Void)?)
    func pop(animated: Bool)
}
