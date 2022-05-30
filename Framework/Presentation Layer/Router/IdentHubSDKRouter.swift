//
//  IdentHubSDKRouter.swift
//  IdentHubSDK
//

import UIKit

/// SDK navigation router exectured all navigation commands and conformed Router protocol
class IdentHubSDKRouter: NSObject, Router {

    // MARK: - Properties -
    
    /// Strong reference to `IdentHubSession` to ensure its alive until the flow is over
    private var identHubSession: IdentHubSession?

    /// Array with all completions block passed as parameter on push/pop/present/dismiss methods
    private var completions: [UIViewController : () -> Void]

    var rootViewController: UIViewController? {
      return navigationController.viewControllers.first
    }

    var navigationController: UINavigationController = UINavigationController()

    /// Init navigation router method with a given root present controller
    /// Sets navigation controller
    /// Initialized completions array with empty array
    /// Sets main navigation controller delegate conforms object
    /// - Parameter navigationController: main navigation controller used in identity flow
    init(rootViewController: UIViewController, identHubSession: IdentHubSession) {
        self.completions = [:]
        self.identHubSession = identHubSession
        
        super.init()
        
        navigationController.delegate = self
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.modalPresentationStyle = .overFullScreen

        rootViewController.present(navigationController, animated: true)
    }

    // MARK: - Public methods -

    /// Method returns main navigation flow controller object
    /// - Returns: main navigation controller
    func toPresentable() -> UIViewController {
      return navigationController
    }

    /// Presents controller on main flow navigaiton controller
    /// - Parameters:
    ///   - module: presented object
    ///   - animated: presenting animation flag
    func present(_ module: Showable, animated: Bool) {

      navigationController.present(module.toShowable(), animated: animated, completion: nil)
    }

    /// Method dimissed showable controller from navigation view
    /// - Parameters:
    ///   - animated: dismissing  animation flag
    ///   - completion: the block to execute after the view controller is dismissed.
    func dismissModule(animated: Bool, completion: (() -> Void)?) {
      identHubSession = nil
        
      navigationController.dismiss(animated: animated, completion: completion)
    }

    /// Method pushed controller to the main navigation stack
    /// - Parameters:
    ///   - module: next viewed screen controller object
    ///   - animated: animate transition boolean flag
    ///   - completion: the block to execute after the view controller is pushed.
    func push(_ module: Showable, animated: Bool = true, completion: (() -> Void)? = nil) {
      // Avoid pushing UINavigationController onto stack
      let controller = module.toShowable()

      // Avoid pushing UINavigationController onto stack
      guard controller is UINavigationController == false else {
        return
      }

      if let completion = completion {
        completions[controller] = completion
      }
      navigationController.pushViewController(controller, animated: animated)
    }

    /// Method poped controller from main navigation stack
    /// - Parameter animated: animate transition boolean flag
    func pop(animated: Bool = true) {

      if let controller = navigationController.popViewController(animated: animated) {
        runCompletion(for: controller)
      }
    }

    // MARK: - Internal methods -

    /// Method executes stored completion block of the controller in stack/view
    /// After executing completion block removes objects from completions storage
    /// - Parameter controller: controller object requires calling transition completion block
    fileprivate func runCompletion(for controller: UIViewController) {
      guard let completion = completions[controller] else {
        return
      }
      completion()
      completions.removeValue(forKey: controller)
    }
}

extension IdentHubSDKRouter: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {

      // Make sure the view controller is popping, not pushing, and check for existence
      guard let poppedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from), !navigationController.viewControllers.contains(poppedViewController) else {
        return
      }

      // As long as the closure is properly setup, it can now be used to clean up any resources
      runCompletion(for: poppedViewController)
    }
}
