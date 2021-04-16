//
//  FourthlineIdentCoordinator.swift
//  IdentHubSDK
//

import UIKit
import AVFoundation

/// Fourthline identification process flow coordinator class
/// Used for navigating between screens and update process status
class FourthlineIdentCoordinator: BaseCoordinator {

    /// The list of all available actions.
    enum Action {
        case termsAndConditions // Privacy statement and Terms-Conditions screen
        case welcome // Welcome screen with all instructions
        case selfie // Make a selfie step
        case documents // Run document scanner step
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
        case .documents:
            presentDocumentScanner()
        case .quit:
            quit()
        }
    }
}

// MARK: - Private methods -

extension FourthlineIdentCoordinator {

    // MARK: - Navigation methods -

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
        requestPermissions { isPassed in
            guard isPassed else { return }

            DispatchQueue.main.async {
                let selfieVM = SelfieViewModel(flowCoordinator: self)
                let selfieVC = SelfieViewController()

                selfieVC.setViewModel(selfieVM)

                self.presenter.push(selfieVC, animated: true, completion: nil)
            }
        }
    }

    private func presentDocumentScanner() {
        let documentScannerVM = DocumentScannerViewModel(flowCoordinator: self)
        let documentScannerVC = DocumentScannerViewController(documentScannerVM)

        presenter.push(documentScannerVC, animated: true, completion: nil)
    }

    // MARK: - Permission methods -
    func requestPermissions(completionHandler: @escaping ((_ isPassed: Bool) -> Void)) {

        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else {
                DispatchQueue.main.async {
                    self.showCameraPermissionAlert()
                }
                print(Localizable.Camera.errorMessage)
                completionHandler(false)
                return
            }

            DispatchQueue.main.async {
                LocationManager.shared.requestLocationAuthorization {
                    completionHandler(true)
                }
            }
        }
    }

    func showCameraPermissionAlert() {

        let alert = UIAlertController(title: Localizable.Camera.permissionErrorAlertTitle, message: Localizable.Camera.permissionErrorAlertMessage, preferredStyle: .alert)

        let tryAgainAction = UIAlertAction(title: Localizable.Common.settings, style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        })

        let cancelAction = UIAlertAction(title: Localizable.Common.cancel, style: .cancel)
        alert.addAction(tryAgainAction)
        alert.addAction(cancelAction)

        presenter.present(alert, animated: true)
    }
}
