//
//  FourthlineIdentCoordinator.swift
//  IdentHubSDK
//

import UIKit

/// Fourthline identification process flow coordinator class
/// Used for navigating between screens and update process status
class FourthlineIdentCoordinator: Coordinator {

    // MARK: - Properties -
    private let presenter: Router

    // MARK: - Init method -

    /// Initiate coordinator object
    /// - Parameter presenter: root navigaiton router in Fourthline flow
    internal init(presenter: Router) {
        self.presenter = presenter
    }

    // MARK: - Coordinator methods -

    /// Method starts Fourthline identificaiton process
    /// - Parameter completion: completion handler with success or failure parameter, used for updating users UI
    func start(completion: @escaping CompletionHandler) {
        let termsConditionsVC = TermsConditionsViewController()

        presenter.push(termsConditionsVC, animated: false, completion: nil)
    }
}
