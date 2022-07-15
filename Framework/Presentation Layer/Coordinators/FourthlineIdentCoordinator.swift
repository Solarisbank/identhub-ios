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

        KYCContainer.shared.restoreData(appDependencies.sessionInfoProvider)
    }

    // MARK: - Coordinator methods -

    /// Method starts Fourthline identificaiton process
    /// - Parameter completion: completion handler with success or failure parameter, used for updating users UI
    override func start(_ completion: @escaping CompletionHandler) {
        fourthlineLog.info("Starting Fourthline identification coordinator")
        
        completionHandler = completion

        executeStep(step: identificationStep)
    }

    /// Performs a specified Fourthline identifiaction action.
    /// - Parameter action: type of the execution action
    func perform(action: FourthlineStep) {
        fourthlineLog.info("Performing action: \(action)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.executeStep(step: action)
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
    
    private func executeStep(step: FourthlineStep) {
        fourthlineLog.debug("executeStep \(step)")
        
        switch step {
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

    private func presentWelcomeScreen() {
        guard let identMethod = self.appDependencies.sessionInfoProvider.identificationStep else { return }
        
        let welcomeVM = WelcomeViewModel(flowCoordinator: self, identMethod: identMethod)
        let welcomeVC = WelcomeViewController(welcomeVM)

        presenter.push(welcomeVC, animated: true, completion: nil)
    }

    private func presentSelfieScreen() {
        requestPermissions { [weak self] isPassed in
            guard isPassed, let self = self else { return }
            
            let selfieVM = SelfieViewModel(flowCoordinator: self)
            let selfieVC = SelfieViewController()

            selfieVC.setViewModel(selfieVM)

            self.presenter.push(selfieVC, animated: true, completion: nil)
        }
    }

    private func presentDataLoader() {
        let fetchDataVM = RequestsViewModel(appDependencies.verificationService, storage: appDependencies.sessionInfoProvider, type: .fetchData, fourthlineCoordinator: self)
        let fetchDataVC = RequestsViewController(fetchDataVM)

        presenter.push(fetchDataVC, animated: true, completion: nil)
    }

    private func presentDocumentPicker() {
        let documentPickerVM = DocumentPickerViewModel(self, infoProvider: appDependencies.sessionInfoProvider)
        let documentPickerVC = DocumentPickerViewController(documentPickerVM)

        presenter.push(documentPickerVC, animated: true, completion: nil)
    }

    private func presentDocumentScanner(_ documentType: DocumentType) {
        requestPermissions { [weak self] isPassed in
            guard isPassed, let self = self else { return }
            
            let documentScannerVM = DocumentScannerViewModel(documentType, flowCoordinator: self)
            let documentScannerVC = DocumentScannerViewController(viewModel: documentScannerVM)

            documentScannerVC.modalPresentationStyle = .fullScreen

            self.presenter.present(documentScannerVC, animated: true)
        }
    }

    private func presentDocumentInfoConfirmation() {
        let documentInfoVM = DocumentInfoViewModel(self)
        let documentInfoVC = DocumentInfoViewController(documentInfoVM)

        presenter.push(documentInfoVC, animated: true, completion: nil)
    }

    private func presentDataUploader() {
        let uploadVM = RequestsViewModel(appDependencies.verificationService, storage: appDependencies.sessionInfoProvider, type: .uploadData, fourthlineCoordinator: self)
        let uploadVC = RequestsViewController(uploadVM)

        presenter.push(uploadVC, animated: true, completion: nil)
    }

    private func presentDataVerification() {
        let verificationVM = RequestsViewModel(appDependencies.verificationService, storage: appDependencies.sessionInfoProvider, type: .confirmation, fourthlineCoordinator: self)
        let verificationVC = RequestsViewController(verificationVM)

        presenter.push(verificationVC, animated: true, completion: nil)
    }

    private func presentResult(_ result: FourthlineIdentificationStatus) {
        let resultVM = ResultViewModel(self)
        resultVM.result = result

        let resultVC = ResultViewController(resultVM)

        presenter.push(resultVC, animated: true, completion: nil)
    }

    private func completeIdent(with result: FourthlineIdentificationStatus) {
        let resultIsInfo = result.identificationStatus == .success || result.identificationStatus == .confirmed
        fourthlineLog.log(
            "Completed identification with \(result.identificationStatus)",
            level: resultIsInfo ? .info : .warn
        )
        
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
        case .authorizationRequired:
            nextStepHandler?(.bankIDQES)
        default:
            fourthlineLog.warn("\(result.identificationStatus) not processed.")
        }
    }

    private func interruptIdentProcess(with error: APIError) {
        fourthlineLog.warn("Interupt ident process with error: \(error)")
        
        DispatchQueue.main.async { [weak self] in
            self?.completionHandler?(.failure(error))
            self?.close()
        }
    }
}

// MARK: - Permission methods -

private extension FourthlineIdentCoordinator {

    private func requestPermissions(completionHandler: @escaping ((_ isPassed: Bool) -> Void)) {
        fourthlineLog.info("Requesting permissions for camera...")
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else {
                fourthlineLog.warn("Permissions for camera not granted")
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.showPermissionAlert(with: Localizable.Camera.permissionErrorAlertTitle, message: Localizable.Camera.permissionErrorAlertMessage)
                    completionHandler(false)
                }
                return
            }
            
            fourthlineLog.info("Permissions for camera granted")
            
            DispatchQueue.main.async {
                fourthlineLog.info("Requesting location permissions...")
                
                LocationManager.shared.requestLocationAuthorization { [weak self] status, error in
                    if status {
                        fourthlineLog.info("Location permissions are granted")
                    } else {
                        fourthlineLog.warn("Location permissions are not granted with error: \(String(describing: error?.localizedDescription))")
                    }
                    
                    if let locationError = error as? APIError {
                        self?.showPermissionAlert(with: Localizable.Location.Error.title, message: locationError.text())
                    }
                    completionHandler(status)
                }
            }
        }
    }
    
    private func showPermissionAlert(with title: String, message: String) {
        fourthlineLog.info("Showing permissions alert \(title)")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let tryAgainAction = UIAlertAction(title: Localizable.Common.settings, style: .default, handler: { _ in
            fourthlineLog.warn("User chose showing iOS settings")
            
            if let url = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                self.close()
            }
        })

        let cancelAction = UIAlertAction(title: Localizable.Common.cancel, style: .cancel) { _ in
            fourthlineLog.warn("Canceled granting permissions by user")
            
            switch self.identificationStep {
            case .documentScanner(_),
                 .selfie:
                self.close()
            default:
                break
            }
            
        }
        alert.addAction(tryAgainAction)
        alert.addAction(cancelAction)

        presenter.present(alert, animated: true)
    }
}
