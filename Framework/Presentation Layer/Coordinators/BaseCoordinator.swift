//
//  BaseCoordinator.swift
//  IdentHubSDK
//

import Foundation

internal class BaseCoordinator: Coordinator {

    // MARK: - Properties -
    internal let presenter: Router

    // MARK: - Init method -

    /// Initiate coordinator object
    /// - Parameter presenter: root navigaiton router in Fourthline flow
    internal init(presenter: Router) {
        self.presenter = presenter
    }

    // MARK: - Public methods -
    func start(_ completion: @escaping CompletionHandler) {}

    // MARK: - Internal methods -
    internal func pop() {
        presenter.pop(animated: true)
    }

    internal func quit(action: @escaping () -> Void) {
        let quitPopUpViewController = QuitPopUpViewController()
        quitPopUpViewController.quitAction = action
        quitPopUpViewController.modalPresentationStyle = .overFullScreen
        presenter.present(quitPopUpViewController, animated: false)
    }

    internal func close() {
        UserDefaults.standard.synchronize()
        
        presenter.dismissModule(animated: false, completion: { [weak self] in
            guard let `self` = self else { return }

            self.presenter.dismissModule(animated: true, completion: nil)
        })
    }
}
