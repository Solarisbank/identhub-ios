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
    private var bankIDCoordinator: BankIDCoordinator?
    private var coordinatorPerformer: FlowCoordinatorPerformer
    private var fourthlineCoordinator: FourthlineCoordinator?

    // MARK: - Init methods -
    init(appDependencies: AppDependencies, presenter: Router) {

        self.appDependencies = appDependencies
        self.coordinatorPerformer = FlowCoordinatorPerformer()

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
            completionHandler?(.failure(.modulesNotFound(missingModules.map { $0.rawValue }.sorted())))
            close()
        }
    }
    
    func configureColors() {
        let colors = ColorsImpl(styleColors: StyleColors.obtainFromStorage())
        appDependencies.serviceLocator.configuration = Configuration(colors: colors)
        appDependencies.updateModuleResolver()
    }
}

// MARK: - Manager Session Tracker methods -

private extension IdentificationCoordinator {
    
    private func execute(action: IdentificationCoordinator.Action) {
        identLog.debug("Executing action \(action)")
        configureColors()

        switch action {
        case .initialization:
            presentInitialScreen()
        case .termsAndConditions:
            presentPrivacyTermsScreen()
        case .phoneVerification:
            presentPhoneVerificationScreen()
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
        startCore(.initateFlow)
        updateAction(action: .initialization)
    }

    private func presentPrivacyTermsScreen() {
        startCore(.termsConditions)
        updateAction(action: .termsAndConditions)
    }
    
    private func presentPhoneVerificationScreen() {
        startCore(.phoneVerification)
        updateAction(action: .phoneVerification)
    }

    private func startIdentProcess() {
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
            presentPhoneVerificationScreen()
        case .bankIBAN,
             .bankIDIBAN:
            startBankID()
        case .fourthline,
             .fourthlineSigning:
            self.startFourthline(.fetchData)
        case .unspecified:
            identLog.error("Identificaiton flow is not specified")
        default:
            identLog.error("Identificaiton flow is not handled")
        }

        updateAction(action: .identification)
    }
    
    private func startCore(_ step: CoreStep) {
        if coreScreensCoordinator == nil {
            coreScreensCoordinator = CoreScreensCoordinator(appDependencies: appDependencies, presenter: presenter)
        }
        coreScreensCoordinator?.currentIdentStep = step
        coreScreensCoordinator?.start(completionHandler!)
        coreScreensCoordinator?.nextStepHandler = { [weak self] nextStep in
            guard let self = self else {
                identLog.error("Cannot handle Core coordinator nextStepHandler. `self` is not present")
                return
            }
            
            switch nextStep {
            case .startIdentification(let session, let response):
                self.appDependencies.sessionInfoProvider = session
                             
                if let res = response {
                    if let colors = res.style?.colors {
                        self.appDependencies.moduleResolver.core?.updateColors(colors:  ColorsImpl(styleColors: colors))
                    }
                    if self.isFourthlineFlow() && res.status == .rejected {
                        self.identificationFailed()
                        return
                    }
                    
                    self.configureColors()
                    DispatchQueue.main.async {
                        self.validateModules(for: response as? Modularizable)
                    }
                }
 
                self.performPrechecksThenProceed()
            case .fourthline(let step, let fourthlineProvider):
                self.appDependencies.sessionInfoProvider.fourthlineProvider = fourthlineProvider
                DispatchQueue.main.async {
                    self.startFourthline(step)
                }
            case .phoneVerificationConfirm:
                self.performPrechecksThenProceed()
            case .abort:
                self.identificationFailed()
            }
        }
    }
    
    private func performPrechecksThenProceed() {
        DispatchQueue.main.async {
            guard let completionHandler = self.completionHandler else { return }
            let session = self.appDependencies.sessionInfoProvider
            
            if (!session.acceptedTC) {
                self.presentPrivacyTermsScreen()
                return
            }
            if (!session.phoneVerified) {
                self.presentPhoneVerificationScreen()
                return
            }
            
            if let identStep = self.appDependencies.sessionInfoProvider.identificationStep {
                if self.isFourthlineFlow() {
                    self.startFourthline(.fetchData)
                } else {
                    if (self.bankIDCoordinator != nil) {
                        self.bankIDCoordinator?.perform(step: identStep, completionHandler)
                    } else {
                        self.startBankID()
                    }
                }
            } else {
                self.identificationFailed()
            }
        }
    }
    
    private func identificationFailed() {
        self.completeIdentification(
            result: .failure(.authorizationFailed),
            shouldClearData: true
        )
    }
    
    private func isFourthlineFlow() -> Bool {
        return (self.appDependencies.sessionInfoProvider.identificationStep == .fourthline ||
                self.appDependencies.sessionInfoProvider.identificationStep == .fourthlineSigning)
    }

    private func startBankID() {
        bankIDCoordinator = BankIDCoordinator(appDependencies: appDependencies, presenter: presenter)
        bankIDCoordinator?.start(completionHandler!)
        updateAction(action: .identification)
    }

    private func updateAction(action: Action) {
        SessionStorage.updateValue(action.rawValue, for: StoredKeys.initialStep.rawValue)
    }
    
    private func startFourthline(_ step: FourthlineStep) {
        guard let completionHandler = completionHandler else {
            identLog.error("Cannot handle startFourthline. IdentificationCoordinator completionHandler is nil.")
            return
        }

        fourthlineCoordinator = FourthlineCoordinator(appDependencies: appDependencies, presenter: presenter)
        bankIDCoordinator = BankIDCoordinator(appDependencies: appDependencies, presenter: presenter)
        
        fourthlineCoordinator?.identificationStep = step
        fourthlineCoordinator?.start(completionHandler)
        
        fourthlineCoordinator?.nextStepHandler = { [weak self] nextStep in
            guard let self = self else {
                identLog.error("Cannot handle fourthline coordinator nextStepHandler. `self` is not present")
                
                return
            }
            identLog.info("Fourthline flow nextStepHandler. Executing next step \(nextStep) on bankId coordinator: \(String(describing: self.bankIDCoordinator))")
            self.bankIDCoordinator?.perform(step: nextStep, self.completionHandler!)
        }
        updateAction(action: .identification)
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
