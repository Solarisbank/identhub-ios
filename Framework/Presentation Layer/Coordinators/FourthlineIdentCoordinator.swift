//
//  FourthlineIdentCoordinator.swift
//  IdentHubSDK
//

import UIKit
import AVFoundation
import FourthlineCore

/// Fourthline identification process flow coordinator class
/// Used for navigating between screens and update process status
class FourthlineIdentCoordinator: BaseCoordinator {

    // MARK: - Properties -
    private let appDependencies: AppDependencies
    private var identificationStep: FourthlineStep = .welcome
    private var completionHandler: CompletionHandler?
    internal var nextStepHandler: ((IdentificationStep) -> Void)?

    // MARK: - Init methods -

    init(appDependencies: AppDependencies, presenter: Router) {
        self.appDependencies = appDependencies

        super.init(presenter: presenter)

        self.restoreStep()
    }

    // MARK: - Coordinator methods -

    /// Method starts Fourthline identificaiton process
    /// - Parameter completion: completion handler with success or failure parameter, used for updating users UI
    override func start(_ completion: @escaping CompletionHandler) {
        completionHandler = completion

        perform(action: identificationStep)
    }

    /// Performs a specified Fourthline identifiaction action.
    /// - Parameter action: type of the execution action
    func perform(action: FourthlineStep) {

        switch action {
        case .welcome:
            presentWelcomeScreen()
        case .selfie:
            presentSelfieScreen()
        case .fetchData:
            presentDataLoader()
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
            presentResult(result)
        case .quit:
            quit {[weak self] in
                self?.interruptIdentProcess(with: .unauthorizedAction)
            }
        case let .complete(result):
            completeIdent(with: result)
        case .nextStep(let step):
            nextStepHandler?(step)
        case .abort:
            interruptIdentProcess(with: .unauthorizedAction)
        case .close(let error):
            interruptIdentProcess(with: error)
        }
    }

    /// Method defined if in navigation stack is exist controller. Used for cases, when user dismissed SDK controller and wants return to the previous step
    /// - Returns: bool value of emptinest of navigation controllers stack
    func isLastController() -> Bool {
        return presenter.navigationController.viewControllers.isEmpty
    }
}

// MARK: - Private methods -

private extension FourthlineIdentCoordinator {

    // MARK: - Navigation methods -

    private func presentWelcomeScreen() {
        let welcomeVM = WelcomeViewModel(flowCoordinator: self)
        let welcomeVC = WelcomeViewController(welcomeVM)

        presenter.push(welcomeVC, animated: true, completion: nil)
        updateFourthlineStep(step: .welcome)
    }

    private func presentSelfieScreen() {
        requestPermissions { isPassed in
            guard isPassed else { return }

            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let identMethod = self.appDependencies.sessionInfoProvider.identificationStep else { return }

                let selfieVM = SelfieViewModel(flowCoordinator: self, identMethod: identMethod)
                let selfieVC = SelfieViewController()

                selfieVC.setViewModel(selfieVM)

                self.presenter.push(selfieVC, animated: true, completion: nil)
                self.updateFourthlineStep(step: .selfie)
            }
        }
    }

    private func presentDataLoader() {
        let fetchDataVM = RequestsViewModel(appDependencies.verificationService, storage: appDependencies.sessionInfoProvider, type: .fetchData, fourthlineCoordinator: self)
        let fetchDataVC = RequestsViewController(fetchDataVM)

        presenter.push(fetchDataVC, animated: true, completion: nil)
        updateFourthlineStep(step: .fetchData)
    }

    private func presentDocumentPicker() {
        let documentPickerVM = DocumentPickerViewModel(self, infoProvider: appDependencies.sessionInfoProvider)
        let documentPickerVC = DocumentPickerViewController(documentPickerVM)

        presenter.push(documentPickerVC, animated: true, completion: nil)
        updateFourthlineStep(step: .documentPicker)
    }

    private func presentDocumentScanner(_ documentType: DocumentType) {
        let documentScannerVM = DocumentScannerViewModel(documentType, flowCoordinator: self)
        let documentScannerVC = DocumentScannerViewController(viewModel: documentScannerVM)

        documentScannerVC.modalPresentationStyle = .fullScreen

        presenter.present(documentScannerVC, animated: true)
        updateFourthlineStep(step: .documentScanner(type: documentType))
    }

    private func presentDocumentInfoConfirmation() {
        updateFourthlineStep(step: .documentInfo)

        let documentInfoVM = DocumentInfoViewModel(self)
        let documentInfoVC = DocumentInfoViewController(documentInfoVM)

        presenter.push(documentInfoVC, animated: true, completion: nil)
    }

    private func presentLocationTracker() {
        let locationVM = LocationViewModel(self)
        let locationVC = LocationViewController(locationVM)

        presenter.push(locationVC, animated: true, completion: nil)
        updateFourthlineStep(step: .location)
    }

    private func presentDataUploader() {
        let uploadVM = RequestsViewModel(appDependencies.verificationService, storage: appDependencies.sessionInfoProvider, type: .uploadData, fourthlineCoordinator: self)
        let uploadVC = RequestsViewController(uploadVM)

        presenter.push(uploadVC, animated: true, completion: nil)
        updateFourthlineStep(step: .upload)
    }

    private func presentDataVerification() {
        let verificationVM = RequestsViewModel(appDependencies.verificationService, storage: appDependencies.sessionInfoProvider, type: .confirmation, fourthlineCoordinator: self)
        let verificationVC = RequestsViewController(verificationVM)

        presenter.push(verificationVC, animated: true, completion: nil)
        updateFourthlineStep(step: .confirmation)
    }

    private func presentResult(_ result: FourthlineIdentificationStatus) {
        let resultVM = ResultViewModel(self)
        resultVM.result = result

        let resultVC = ResultViewController(resultVM)

        presenter.push(resultVC, animated: true, completion: nil)
        updateFourthlineStep(step: .result(result: result))
    }

    private func completeIdent(with result: FourthlineIdentificationStatus) {

        switch result.identificationStatus {
        case .success:
            completionHandler?(.success(identification: result.identification))
            close()
        case .identificationRequired:
            completionHandler?(.success(identification: result.identification))
        case .failed:
            completionHandler?(.failure(.authorizationFailed))
            close()
        case .confirmed:
            completionHandler?(.onConfirm(identification: result.identification))
            close()
        default:
            print("\(result.identificationStatus) not processed.")
        }
    }

    private func interruptIdentProcess(with error: APIError) {
        DispatchQueue.main.async { [weak self] in
            self?.completionHandler?(.failure(error))
            self?.close()
        }
    }
}

// MARK: - Save / load ident data -

private extension FourthlineIdentCoordinator {

    private func restoreStep() {
        guard let restoreData = SessionStorage.obtainValue(for: StoredKeys.fourthlineStep.rawValue) as? Data else { return }

        if let step = try? JSONDecoder().decode(FourthlineStep.self, from: restoreData) {
            identificationStep = step
            KYCContainer.shared.restoreData(appDependencies.sessionInfoProvider)
        }
    }

    private func updateFourthlineStep(step: FourthlineStep) {
        if let stepData = try? JSONEncoder().encode(step) {
            SessionStorage.updateValue(stepData, for: StoredKeys.fourthlineStep.rawValue)
        }
    }
}

// MARK: - Permission methods -

private extension FourthlineIdentCoordinator {

    private func requestPermissions(completionHandler: @escaping ((_ isPassed: Bool) -> Void)) {

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

    private func showCameraPermissionAlert() {

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
