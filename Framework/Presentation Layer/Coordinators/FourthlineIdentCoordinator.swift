//
//  FourthlineIdentCoordinator.swift
//  IdentHubSDK
//

import UIKit

/// Fourthline identification process flow coordinator class
/// Used for navigating between screens and update process status
class FourthlineIdentCoordinator: BaseCoordinator {

    /// The list of all available actions.
    enum Action {
        case termsAndConditions // Privacy statement and Terms-Conditions screen
        case welcome // Welcome screen with all instructions
        case selfie // Make a selfie step
        case quit // Quit from identification process
    }

    // MARK: - Coordinator methods -

    /// Method starts Fourthline identificaiton process
    /// - Parameter completion: completion handler with success or failure parameter, used for updating users UI
    override func start(completion: @escaping CompletionHandler) {
        perform(action: .termsAndConditions)
    }

    /// Performs a specified Fourthline identifiaction action.
    /// - Parameter action: type of the execution action
    func perform(action: FourthlineIdentCoordinator.Action) {

        switch action {
        case .termsAndConditions:
            presentPrivacyTermsScreen()
        case .welcome:
            presentWelcomeScreen()
        case .selfie:
            presentSefieScreen()
        case .quit:
            quit()
        }
    }

    // MARK: - Internal methods -

    private func presentPrivacyTermsScreen() {
        let termsVM = TermsViewModel(flowCoordinator: self)
        let termsVC = TermsViewController(termsVM)

        presenter.push(termsVC, animated: false, completion: nil)
    }

    private func presentWelcomeScreen() {
        let welcomeVM = WelcomeViewModel(flowCoordinator: self)
        let welcomeVC = WelcomeViewController(welcomeVM)

        presenter.push(welcomeVC, animated: true, completion: nil)
    }

    private func presentSefieScreen() {
        let selfieVM = SelfieViewModel(flowCoordinator: self)
        let selfieVC = SelfieViewController(selfieVM)

        presenter.push(selfieVC, animated: true, completion: nil)
    }
}
