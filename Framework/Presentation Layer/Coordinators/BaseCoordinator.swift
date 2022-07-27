//
//  BaseCoordinator.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

internal class BaseCoordinator: Coordinator {

    // MARK: - Properties -
    internal let presenter: Router
    private let appDependencies: AppDependencies
    private let actionPerformer: ActionPerformer

    // MARK: - Init method -

    /// Initiate coordinator object
    /// - Parameter presenter: root navigaiton router in Fourthline flow
    internal init(presenter: Router, appDependencies: AppDependencies) {
        self.presenter = presenter
        self.appDependencies = appDependencies
        self.actionPerformer = ActionPerformer()
    }

    // MARK: - Public methods -
    func start(_ completion: @escaping CompletionHandler) {}

    // MARK: - Internal methods -
    internal func pop() {
        presenter.pop(animated: true)
    }

    internal func quit(action: @escaping () -> Void) {
        let quitAction = QuitAction(colors: appDependencies.serviceLocator.configuration.colors)
        actionPerformer.performAction(quitAction) { isQuitting in
            if isQuitting { action() }
            return true
        }?.present(on: presenter, animated: false)
    }

    internal func close() {
        UserDefaults.standard.synchronize()

        presenter.dismissModule(animated: false, completion: { [weak self] in
            guard let `self` = self else { return }

            self.presenter.dismissModule(animated: true, completion: nil)
        })
    }
}
