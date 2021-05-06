//
//  FourthlineIdentCoordinator.swift
//  IdentHubSDK
//

import UIKit
import AVFoundation
import FourthlineCore

/// Enumeration with all Fourthline flow steps
enum FourthlineSteps: Int {
    case selfie = 0, document, confirm, upload, result
}

/// Fourthline identification process flow coordinator class
/// Used for navigating between screens and update process status
class FourthlineIdentCoordinator: BaseCoordinator {

    /// The list of all available actions.
    enum Action {
        case welcome // Welcome screen with all instructions
        case selfie // Make a selfie step
        case documentPicker // Present document picker step
        case documentScanner(type: DocumentType) // Present document scanner for document with type: passport, idCard, etc.
        case documentInfo // Verify and confirm scanned document detail
        case location // Fetch device location coordinates
        case upload // Upload collected data to the server
        case confirmation // Confirm or fail user identification request
        case result(result: FourthlineIdentificationStatus) // Result screen with result status
        case quit // Quit from identification process
    }

    // MARK: - Properties -
    private let appDependencies: AppDependencies
    private var identificationStep: Action = .welcome

    // MARK: - Init methods -

    init(appDependencies: AppDependencies, presenter: Router) {

        self.appDependencies = appDependencies

        super.init(presenter: presenter)
    }

    // MARK: - Coordinator methods -

    /// Method starts Fourthline identificaiton process
    /// - Parameter completion: completion handler with success or failure parameter, used for updating users UI
    override func start(_ completion: @escaping CompletionHandler) {
        perform(action: .welcome)
    }

    /// Performs a specified Fourthline identifiaction action.
    /// - Parameter action: type of the execution action
    func perform(action: FourthlineIdentCoordinator.Action) {

        switch action {
        case .welcome:
            presentWelcomeScreen()
        case .selfie:
            presentSefieScreen()
        case .documentPicker:
            presentDocumentPicker()
        case let .documentScanner(type):
            presentDocumentScanner(type)
        case .documentInfo:
            presentDocumentInfoConfirmation()
        case .location:
            presentLocationTracker()
        case .upload:
            presentDataUploader()
        case .confirmation:
            presentDataVerification()
        case let .result(result):
            print("Identification result: \(result.identificationStatus)")
        case .quit:
            quit()
        }
    }
}

// MARK: - Private methods -

private extension FourthlineIdentCoordinator {

    // MARK: - Navigation methods -

    private func presentWelcomeScreen() {
        let welcomeVM = WelcomeViewModel(flowCoordinator: self)
        let welcomeVC = WelcomeViewController(welcomeVM)

        presenter.push(welcomeVC, animated: true, completion: nil)
    }

    private func presentSefieScreen() {
        requestPermissions { isPassed in
            guard isPassed else { return }

            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }

                let selfieVM = SelfieViewModel(flowCoordinator: self)
                let selfieVC = SelfieViewController()

                selfieVC.setViewModel(selfieVM)

                self.presenter.push(selfieVC, animated: true, completion: nil)
                self.identificationStep = .selfie
            }
        }
    }

    private func presentDocumentPicker() {
        let documentPickerVM = DocumentPickerViewModel(self)
        let documentPickerVC = DocumentPickerViewController(documentPickerVM)

        presenter.push(documentPickerVC, animated: true, completion: nil)
        identificationStep = .documentPicker
    }

    private func presentDocumentScanner(_ documentType: DocumentType) {
        let documentScannerVM = DocumentScannerViewModel(documentType, flowCoordinator: self)
        let documentScannerVC = DocumentScannerViewController(viewModel: documentScannerVM)

        documentScannerVC.modalPresentationStyle = .fullScreen

        presenter.present(documentScannerVC, animated: true)
        identificationStep = .documentScanner(type: documentType)
    }

    private func presentDocumentInfoConfirmation() {
        let documentInfoVM = DocumentInfoViewModel(self)
        let documentInfoVC = DocumentInfoViewController(documentInfoVM)

        presenter.push(documentInfoVC, animated: true, completion: nil)
        identificationStep = .documentInfo
    }

    private func presentLocationTracker() {
        let locationVM = LocationViewModel(self)
        let locationVC = LocationViewController(locationVM)

        presenter.push(locationVC, animated: true, completion: nil)
        identificationStep = .location
    }

    private func presentDataUploader() {
        let uploadVM = RequestsViewModel(appDependencies.verificationService, storage: appDependencies.sessionInfoProvider, type: .uploadData, fourthlineCoordinator: self)
        let uploadVC = RequestsViewController(uploadVM)

        presenter.push(uploadVC, animated: true, completion: nil)
        identificationStep = .upload
    }

    private func presentDataVerification() {
        let verificationVM = RequestsViewModel(appDependencies.verificationService, storage: appDependencies.sessionInfoProvider, type: .confirmation, fourthlineCoordinator: self)
        let verificationVC = RequestsViewController(verificationVM)

        presenter.push(verificationVC, animated: true, completion: nil)
        identificationStep = .confirmation
    }

    // MARK: - Permission methods -
    func requestPermissions(completionHandler: @escaping ((_ isPassed: Bool) -> Void)) {

        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard granted else {
                DispatchQueue.main.async {
                    self?.showCameraPermissionAlert()
                }
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
