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
    private var fourthlineCoordinator: FourthlineCoordinator?
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
                presentConfirmApplication(step: .unspecified)
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
        case .startIdentification, .bankVerification(step: .iban), .nextStep:
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
            presentConfirmApplication(step: step)
        case .fourthline,
            .fourthlineSigning:
            presentFourthlineFlow()
        case .abort:
            completionHandler?(.failure(.unauthorizedAction))
            close()
        case .partnerFallback:
            completionHandler?(.failure(.identificationNotPossible))
            close()
        case .mobileNumber, .unspecified:
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
    
    // MARK: - BANK

    private func presentIBANVerification() {
        presentBank(step: .bankVerification(step: .iban))
        updateBankIDStep(step: .bankVerification(step: .iban))
    }

    private func presentPaymentVerification() {
        presentBank(step: .bankVerification(step: .payment))
        updateBankIDStep(step: .bankVerification(step: .payment))
    }
    
    private func presentBank(step: BankStep) {
        guard let bank = appDependencies.moduleResolver.bank?.makeBankCoordinator() else {
            completionHandler?(.failure(.modulesNotFound([ModuleName.bank.rawValue])))
            close()
            return
        }
        let bankInput = BankInput(
            step: step,
            sessionToken: appDependencies.sessionInfoProvider.sessionToken,
            retriesCount: appDependencies.sessionInfoProvider.retries,
            fallbackIdentStep: appDependencies.sessionInfoProvider.fallbackIdentificationStep,
            identificationUID: appDependencies.sessionInfoProvider.identificationUID ?? "",
            identificationStep: appDependencies.sessionInfoProvider.identificationStep
        )
        coordinatorPerformer.startCoordinator(bank, input: bankInput, callback: { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return true
            }
            
            switch result {
            case .success(let output):
                switch output {
                case .performQES(identID: let identUID):
                    self.appDependencies.sessionInfoProvider.identificationUID = identUID
                    self.presentConfirmApplication(step: .unspecified)
                case .nextStep(step: let step, let identUID):
                    self.appDependencies.sessionInfoProvider.identificationUID = identUID
                    self.perform(action: .nextStep(step: step))
                case .failure(let error):
                    self.completeIdentification(result: .failure(error), shouldClearData: true)
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
    
    // MARK: - QES

    private func presentConfirmApplication(step: IdentificationStep) {
        DispatchQueue.main.async {
            self.presentQES(step: .confirmAndSignDocuments, currentStep: step)
            self.updateBankIDStep(step: .signDocuments(step: .confirmApplication))
        }
    }

    private func presentSignDocuments() {
        DispatchQueue.main.async {
            self.presentQES(step: .signDocuments)
            self.updateBankIDStep(step: .signDocuments(step: .sign))
        }
    }

    private func presentQES(step: QESStep, currentStep: IdentificationStep = .unspecified) {
        guard let identificationUID = appDependencies.sessionInfoProvider.identificationUID else {
            bankLog.error("Cannot handle QESStep step: No identificationUID")
            return
        }
        guard let qes = appDependencies.moduleResolver.qes?.makeQESCoordinator() else {
            completionHandler?(.failure(.modulesNotFound([ModuleName.qes.rawValue])))
            close()
            return
        }
        let input = QESInput(
            step: step,
            identificationUID: identificationUID,
            mobileNumber: appDependencies.sessionInfoProvider.mobileNumber,
            identificationStep: currentStep
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

        self.completionHandler?(IdentificationSessionResult.onConfirm(identification: self.appDependencies.sessionInfoProvider.identificationUID ?? ""))
    }
    
    // MARK: - Fourthline
    
    private func presentFourthlineFlow() {
        guard let completionHandler = completionHandler else {
            bankLog.error("Cannot handle presentFourthlineFlow. BankIDCoordinator completionHandler is nil.")
            return
        }
       
        fourthlineCoordinator = FourthlineCoordinator(appDependencies: appDependencies, presenter: presenter)
        fourthlineCoordinator?.identificationStep = .fetchData
        fourthlineCoordinator?.start(completionHandler)
        
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
