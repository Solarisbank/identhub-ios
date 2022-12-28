//
//  IdentificationCoordinator.swift
//  IdentHubSDK
//

import UIKit
import IdentHubSDKCore

class IdentificationCoordinator: BaseCoordinator {

    /// The list of all available actions.
    enum Action: Int {
        case initialization = 1 // Screen with init requests to the server for obtaining init data
        case termsAndConditions = 2 // Privacy statement and Terms-Conditions screen
        case identification = 3 // Start identification process
        case phoneVerification = 4 // Mobile number verification
        case quit = 5 // Quit from identification process
        case abort = 6 // Close identification session with throwing error
    }

    // MARK: - Properties -
    private let appDependencies: AppDependencies
    private var completionHandler: CompletionHandler?
    private var executedStep: Action = .initialization
    private var identificationMethod: IdentificationStep?
    private var coreScreensCoordinator: CoreScreensCoordinator?
    private var fourthlineCoordinator: FourthlineIdentCoordinator?
    private var bankIDSessionCoordinator: BankIDCoordinator?

    // MARK: - Init methods -
    init(appDependencies: AppDependencies, presenter: Router) {

        self.appDependencies = appDependencies

        super.init(
            presenter: presenter,
            appDependencies: appDependencies
        )
    }

    // MARK: - Public methods -

    override func start(_ completion: @escaping CompletionHandler) {
        identLog.info("Starting identification coordinator")
        
        completionHandler = completion

        if let step = SessionStorage.obtainValue(for: StoredKeys.initialStep.rawValue) as? Int {
            executedStep = Action(rawValue: step) ?? .initialization
        }

        execute(action: executedStep)
    }

    func perform(action: IdentificationCoordinator.Action) {
        identLog.info("Performing action \(action)")
        
        DispatchQueue.main.async { [weak self] in
            self?.execute(action: action)
        }
    }
    
    func validateModules(for modularizable: Modularizable?) {
        guard let modularizable = modularizable else {
            return
        }
        let missingModules = modularizable.requiredModules
            .subtracting(appDependencies.moduleResolver.availableModules)
        
        if missingModules.isNotEmpty() {
            completionHandler?(.failure(.modulesNotFound(missingModules.map { $0.rawValue })))
            close()
        }
    }
    
    func configureColors() {
        let colors = ColorsImpl(styleColors: StyleColors.obtainFromStorage())
        appDependencies.serviceLocator.configuration = Configuration(colors: colors)
    }
}

// MARK: - Manager Session Tracker methods -

private extension IdentificationCoordinator {
    
    private func execute(action: IdentificationCoordinator.Action) {
        identLog.debug("Executing action \(action)")
        
        switch action {
        case .initialization:
            presentInitialScreen()
        case .termsAndConditions:
            presentPrivacyTermsScreen()
        case .phoneVerification:
            startCore()
        case .identification:
            startIdentProcess()
        case .quit:
            quit { [weak self] in
                self?.completionHandler?(.failure(.unauthorizedAction))
                self?.close()
            }
        case .abort:
            completionHandler?(.failure(.authorizationFailed))
            close()
        }
    }

    private func presentInitialScreen() {
        let requestVM = RequestsViewModel(appDependencies.verificationService, storage: appDependencies.sessionInfoProvider, type: .initateFlow, identCoordinator: self)
        requestVM.onActionPerformed = { [weak self] in
            self?.performPrechecksThenProceed()
        }
        let requestVC = RequestsViewController(requestVM)

        let animated = presenter.navigationController.viewControllers.isNotEmpty()
        presenter.push(requestVC, animated: animated, completion: nil)
        executedStep = .initialization
        updateAction(action: .initialization)
    }
    
    private func performPrechecksThenProceed() {
        let storage = appDependencies.sessionInfoProvider
        if !storage.acceptedTC && !storage.performedTCAcceptance {
            perform(action: .termsAndConditions)
            return
        }
        if !storage.phoneVerified && !storage.performedPhoneVerification {
            perform(action: .phoneVerification)
            return
        }
        perform(action: .identification)
    }

    private func presentPrivacyTermsScreen() {
        let termsVM = TermsViewModel(coordinator: self)
        termsVM.onActionPerformed = { [weak self] in
            self?.appDependencies.sessionInfoProvider.performedTCAcceptance = true
            self?.performPrechecksThenProceed()
        }
        let termsVC = TermsViewController(termsVM)

        presenter.push(termsVC, animated: false, completion: nil)
        executedStep = .termsAndConditions
        updateAction(action: .termsAndConditions)
    }

    private func startIdentProcess() {
        configureColors()

        if let method = appDependencies.sessionInfoProvider.identificationStep {
            identificationMethod = method
        } else if let method = SessionStorage.obtainValue(for: StoredKeys.identMethod.rawValue) as? String {
            identificationMethod = IdentificationStep(rawValue: method)
        }

        initiateMethod()
    }

    private func initiateMethod() {
        identLog.info("Initiating identification method \(String(describing: identificationMethod))")
        
        switch identificationMethod {
        case .mobileNumber:
            startCore()
        case .bankIBAN,
             .bankIDIBAN:
            startBankID()
        case .fourthline,
             .fourthlineSigning:
            startFourthline()
        case .unspecified:
            identLog.error("Identificaiton flow is not specified")
        default:
            identLog.error("Identificaiton flow is not handled")
        }

        executedStep = .identification
        updateAction(action: .identification)
    }
    
    private func startCore() {
        configureColors()
        coreScreensCoordinator = CoreScreensCoordinator(appDependencies: appDependencies, presenter: presenter)
        
        coreScreensCoordinator?.start(completionHandler!)
        
        coreScreensCoordinator?.coreScreensDoneHandler = { [weak self] in
            self?.appDependencies.sessionInfoProvider.performedPhoneVerification = true
            self?.performPrechecksThenProceed()
        }
    }

    private func startBankID() {
        bankIDSessionCoordinator = BankIDCoordinator(appDependencies: appDependencies, presenter: presenter)

        bankIDSessionCoordinator?.start(completionHandler!)
    }

    private func startFourthline() {
        fourthlineCoordinator = FourthlineIdentCoordinator(appDependencies: appDependencies, presenter: presenter)
        bankIDSessionCoordinator = BankIDCoordinator(appDependencies: appDependencies, presenter: presenter)

        fourthlineCoordinator?.start(completionHandler!)

        fourthlineCoordinator?.nextStepHandler = { [weak self] nextStep in
            guard let self = self else {
                identLog.error("Cannot handle fourthline coordinator nextStepHandler. `self` is not present")
                
                return
            }
            
            identLog.info("Fourthline flow nextStepHandler. Executing next step \(nextStep) on bankId coordinator: \(String(describing: self.bankIDSessionCoordinator))")

            self.bankIDSessionCoordinator?.perform(step: nextStep, self.completionHandler!)
        }
    }

    private func updateAction(action: Action) {
        SessionStorage.updateValue(action.rawValue, for: StoredKeys.initialStep.rawValue)
    }
}
