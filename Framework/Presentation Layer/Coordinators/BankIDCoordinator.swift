//
//  IdentHubSDKCoordinator.swift
//  IdentHubSDK
//

import UIKit
import IdentHubSDKCore

class BankIDCoordinator: BaseCoordinator {

    // MARK: - Properties -
    private let appDependencies: AppDependencies
    private var currentIdentStep: BankIDStep = .startIdentification
    private var completionHandler: CompletionHandler?
    private var fourthlineCoordinator: FourthlineIdentCoordinator?
    private var coordinatorPerformer: FlowCoordinatorPerformer

    // MARK: - Init methods -
    init(appDependencies: AppDependencies, presenter: Router) {

        self.appDependencies = appDependencies
        self.coordinatorPerformer = FlowCoordinatorPerformer()

        super.init(
            presenter: presenter,
            appDependencies: appDependencies
        )

        restoreStep()
    }

    // MARK: - Public methods -

    /// Performs a specified action.
    func perform(action: BankIDStep) {
        bankLog.info("Performing action: \(action)")
        
        switch action {
        case .startIdentification:
            presentStartIdentification()
        case .phoneVerification:
            presentPhoneVerification()
        case .bankVerification(let step):
            switch step {
            case .iban:
                presentIBANVerification()
            case .payment:
                presentPaymentVerification()
            }
        case .signDocuments(let step):
            switch step {
            case .confirmApplication:
                presentConfirmApplication()
            case .sign:
                presentSignDocuments()
            }
        case .finishIdentification:
            // not used
            break
        case .nextStep(let step):
            performIdentStep(step: step)
        case .notifyHandlers:
            notifyHandlers()
        case .pop:
            pop()
        case .quit:
            quit { [weak self] in
                self?.completionHandler?(.failure(.unauthorizedAction))
                self?.close()
            }
        case .close:
            close()
        }
    }

    // MARK: - Coordinator methods -
    override func start(_ completion: @escaping CompletionHandler) {
        bankLog.info("Starting bank id coordinator")
        
        completionHandler = completion
        
        checkIdentificationStatusIfNeededAndProceed()
    }

    /// Method performs Identify step with completion handler
    /// - Parameters:
    ///   - step: IdentifcationStep value
    ///   - completion: completion ident process handler
    func perform(step: IdentificationStep, _ completion: @escaping CompletionHandler) {
        bankLog.info("Performing step \(step)")
        
        completionHandler = completion
        performIdentStep(step: step)
    }
}

// MARK: - Save / load ident data -

extension BankIDCoordinator {

    private func restoreStep() {
        guard let restoreData = SessionStorage.obtainValue(for: StoredKeys.bankIDStep.rawValue) as? Data else {

            if let identStep = appDependencies.sessionInfoProvider.identificationStep {
                currentIdentStep = .nextStep(step: identStep)
            }
            return
        }

        do {
            let step = try JSONDecoder().decode(BankIDStep.self, from: restoreData)
            currentIdentStep = step
            KYCContainer.shared.restoreData(appDependencies.sessionInfoProvider)
        } catch {
            bankLog.warn("Stored bank id step data decoding failed: \(error.localizedDescription).\nIdentification process would be started from beginning")
        }
    }

    private func updateBankIDStep(step: BankIDStep) {
        do {
            let stepData = try JSONEncoder().encode(step)
            SessionStorage.updateValue(stepData, for: StoredKeys.bankIDStep.rawValue)
        } catch {
            bankLog.warn("Coding bank id step data failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Check identification status

extension BankIDCoordinator {
    private func isIdentificationStatusCheckNeeded() -> Bool {
        switch currentIdentStep {
        case .startIdentification, .phoneVerification, .bankVerification(step: .iban), .nextStep:
            return false
        default:
            return true
        }
    }
    
    private func checkIdentificationStatusIfNeededAndProceed() {
        if isIdentificationStatusCheckNeeded() {
            pushLoadingView()
            
            checkIdentificationStatus { [weak self] result in
                result
                    .onSuccess { status in
                        switch status {
                        case .expired, .aborted, .rejected, .canceled, .failed:
                            DispatchQueue.main.async {
                                self?.presentIBANVerification()
                            }
                        default:
                            DispatchQueue.main.async {
                                self?.performActionWithCurrentIdentStep()
                            }
                        }
                    }
                    .onFailure { error in
                        DispatchQueue.main.async {
                            self?.presentAlert(
                                with: Localizable.Common.defaultErr,
                                action: Localizable.Common.tryAgain,
                                error: error.apiError
                            ) { shouldRetry in
                                DispatchQueue.main.async {
                                    if shouldRetry {
                                        self?.checkIdentificationStatusIfNeededAndProceed()
                                    } else {
                                        self?.completionHandler?(.failure(.authorizationFailed))
                                        self?.perform(action: .close)
                                    }
                                }
                            }
                        }
                    }
            }
        } else {
            performActionWithCurrentIdentStep()
        }
    }
    
    private func checkIdentificationStatus(_ completion: @escaping (Result<Status, ResponseError>) -> Void) {
        appDependencies.verificationService.getIdentification { result in
            completion(result.map { $0.status })
        }
    }
    
    private func performActionWithCurrentIdentStep() {
        perform(action: currentIdentStep)
    }
    
    private func pushLoadingView() {
        let loadingViewController = LoadingViewController()
        
        loadingViewController.quitHandler = { [weak self] in
            self?.perform(action: .quit)
        }
        
        presenter.push(loadingViewController.toShowable(), animated: false, completion: nil)
    }
    
    private func presentAlert(with title: String, action: String, error: APIError, callback: @escaping (Bool) -> Void) {
        let message = error.text()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let reactionAction = UIAlertAction(title: action, style: .default, handler: { _ in
            callback(true)
        })

        let cancelAction = UIAlertAction(title: Localizable.Common.dismiss, style: .cancel, handler: { _ in
            callback(false)
        })

        alert.addAction(reactionAction)
        alert.addAction(cancelAction)

        presenter.present(alert.toShowable(), animated: true)
    }
}

// MARK: - Navigation methods -

private extension BankIDCoordinator {
    private func performIdentStep(step: IdentificationStep) {
        bankLog.debug("Performing ident step \(step)")
        switch step {
        case .mobileNumber:
            presentPhoneVerification()
        case .bankIBAN,
             .bankIDIBAN:
            if currentIdentStep != .bankVerification(step: .iban) { // If user already on IBAN screen no reason open it once again
                presentIBANVerification()
            }
        case .bankIDFourthline:
            presentFourthlineFlow()
        case .bankQES,
             .bankIDQES,
             .fourthlineQES:
            presentConfirmApplication()
        case .fourthline,
            .fourthlineSigning:
            presentFourthlineFlow()
        case .abort:
            completionHandler?(.failure(.unauthorizedAction))
            close()
        case .partnerFallback:
            completionHandler?(.failure(.identificationNotPossible))
            close()
        case .unspecified:
            bankLog.error("Step is not supported or not specified yet")
            
            completionHandler?(.failure(.unsupportedResponse))
            close()
        }
    }

    private func presentStartIdentification() {
        let startIdentificationViewModel = StartIdentificationViewModel(flowCoordinator: self)
        let startIdentificationViewController = StartBankIdentViewController(startIdentificationViewModel)

        let animated = presenter.navigationController.viewControllers.isNotEmpty()
        presenter.push(startIdentificationViewController, animated: animated, completion: nil)
        updateBankIDStep(step: .startIdentification)
    }

    private func presentPhoneVerification() {
        let phoneVerificationViewModel = PhoneVerificationViewModel(flowCoordinator: self, verificationService: appDependencies.verificationService, sessionStorage: appDependencies.sessionInfoProvider, completion: completionHandler!)
        let phoneVerificationViewController = PhoneVerificationViewController(phoneVerificationViewModel)
        presenter.push(phoneVerificationViewController, animated: true, completion: nil)
        updateBankIDStep(step: .phoneVerification)
    }

    private func presentIBANVerification() {
        guard appDependencies.sessionInfoProvider.phoneVerified else {
            perform(action: .phoneVerification)
            return
        }

        let ibanVerificationViewModel = IBANVerificationViewModel(flowCoordinator: self, verificationService: appDependencies.verificationService, sessionStorage: appDependencies.sessionInfoProvider, completion: completionHandler!)
        let ibanVerificationViewController = IBANVerificationViewController(ibanVerificationViewModel)

        ibanVerificationViewModel.delegate = ibanVerificationViewController

        let animated = presenter.navigationController.viewControllers.isNotEmpty()
        presenter.push(ibanVerificationViewController, animated: animated, completion: nil)
        updateBankIDStep(step: .bankVerification(step: .iban))
    }

    private func presentPaymentVerification() {
        let paymentVerificationViewModel = PaymentVerificationViewModel(flowCoordinator: self, verificationService: appDependencies.verificationService, sessionStorage: appDependencies.sessionInfoProvider, completion: completionHandler!)
        let paymentVerificationViewController = PaymentVerificationViewController(paymentVerificationViewModel)

        paymentVerificationViewModel.delegate = paymentVerificationViewController

        let animated = presenter.navigationController.viewControllers.isNotEmpty()
        presenter.push(paymentVerificationViewController, animated: animated, completion: nil)
        updateBankIDStep(step: .bankVerification(step: .payment))
    }

    private func presentConfirmApplication() {
        presentQES(step: .confirmAndSignDocuments)
        updateBankIDStep(step: .signDocuments(step: .confirmApplication))
    }

    private func presentSignDocuments() {
        presentQES(step: .signDocuments)
        updateBankIDStep(step: .signDocuments(step: .sign))
    }

    private func presentQES(step: QESStep) {
        guard let identificationUID = appDependencies.sessionInfoProvider.identificationUID else {
            print("Error: No identificationUID")
            return
        }
        guard let qes = appDependencies.moduleResolver.qes?.makeQESCoordinator() else {
            print("Error: QES module not found")
            return
        }
        let input = QESInput(
            step: step,
            identificationUID: identificationUID,
            mobileNumber: appDependencies.sessionInfoProvider.mobileNumber
        )
        coordinatorPerformer.startCoordinator(qes, input: input, callback: { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return true
            }

            switch result {
            case .success(let output):
                switch output {
                case .identificationConfirmed(let identificationToken):
                    self.completeIdentification(
                        result: .onConfirm(identification: identificationToken),
                        shouldClearData: true
                    )
                case .abort:
                    self.completeIdentification(
                        result: .failure(.authorizationFailed),
                        shouldClearData: true
                    )
                }
            case .failure(let error):
                self.completeIdentification(result: .failure(error), shouldClearData: true)
            }
            return true
        })?.push(on: presenter)
    }

    private func notifyHandlers() {
        guard let successStatus = self.appDependencies.sessionInfoProvider.isSuccessful, successStatus == true else { return }

        self.completionHandler?(IdentificationSessionResult.success(identification: self.appDependencies.sessionInfoProvider.identificationUID ?? ""))
    }

    private func presentFourthlineFlow() {
        fourthlineCoordinator = FourthlineIdentCoordinator(appDependencies: appDependencies, presenter: presenter)

        fourthlineCoordinator?.start { [weak self] result in
            guard let self = self else {
                bankLog.error("Cannot handle fourthline coordinator start completion. `self` is not present")
                
                return
            }
            
            switch result {
            case .success( _ ):
                self.presentSignDocuments()
            case .failure( _ ):
                self.completionHandler?(result)
            case .onConfirm( _ ):
                bankLog.debug("Fourthline signing confirmed")
            }
        }

        fourthlineCoordinator?.nextStepHandler = { [weak self] nextStep in
            guard let self = self else {
                bankLog.error("Cannot handle fourthline coordinator nextStepHandler. `self` is not present")
                
                return
            }
            
            bankLog.info("Fourthline flow nextStepHandler. Performing step \(nextStep)")

            self.performIdentStep(step: nextStep)
        }

        updateBankIDStep(step: .nextStep(step: .bankIDFourthline))
    }
    
    private func completeIdentification(result: IdentificationSessionResult, shouldClearData: Bool) {
        if shouldClearData {
            SessionStorage.clearData()
            appDependencies.serviceLocator.modulesStorageManager.clearAllData()
        }
        close()
        completionHandler?(result)
    }
}
