//
//  IdentificationCoordinator.swift
//  IdentHubSDK
//

import UIKit

class IdentificationCoordinator: BaseCoordinator {

    /// The list of all available actions.
    enum Action: Int {
        case initialization = 1 // Screen with init requests to the server for obtaining init data
        case termsAndConditions = 2 // Privacy statement and Terms-Conditions screen
        case identification = 3 // Start identification process
        case quit = 4 // Quit from identification process
        case abort = 5 // Close identification session with throwing error
    }

    // MARK: - Properties -
    private let appDependencies: AppDependencies
    private var completionHandler: CompletionHandler?
    private var documentExporter: DocumentExporter = DocumentExporterService()
    private var executedStep: Action = .initialization
    private var identificationMethod: IdentificationStep?
    private var fourthlineCoordinator: FourthlineIdentCoordinator?
    private var bankIDSessionCoordinator: BankIDCoordinator?

    // MARK: - Init methods -
    init(appDependencies: AppDependencies, presenter: Router) {

        self.appDependencies = appDependencies

        super.init(presenter: presenter)
    }

    // MARK: - Public methods -

    override func start(_ completion: @escaping CompletionHandler) {
        completionHandler = completion

        if let step = SessionStorage.obtainValue(for: StoredKeys.initialStep.rawValue) as? Int {
            executedStep = Action(rawValue: step) ?? .initialization
        }

        execute(action: executedStep)
    }

    func perform(action: IdentificationCoordinator.Action) {

        DispatchQueue.main.async { [weak self] in
            self?.execute(action: action)
        }
    }
}

// MARK: - Manager Session Tracker methods -

private extension IdentificationCoordinator {
    
    private func execute(action: IdentificationCoordinator.Action) {
        
        switch action {
        case .initialization:
            presentInitialScreen()
        case .termsAndConditions:
            presentPrivacyTermsScreen()
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
        let requestVC = RequestsViewController(requestVM)

        presenter.push(requestVC, animated: true, completion: nil)
        executedStep = .initialization
        updateAction(action: .initialization)
    }

    private func presentPrivacyTermsScreen() {
        let termsVM = TermsViewModel(coordinator: self)
        let termsVC = TermsViewController(termsVM)

        presenter.push(termsVC, animated: false, completion: nil)
        executedStep = .termsAndConditions
        updateAction(action: .termsAndConditions)
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

        switch identificationMethod {
        case .mobileNumber,
             .bankIBAN,
             .bankIDIBAN:
            startBankID()
        case .fourthline,
             .fourthlineSigning:
            startFourthline()
        case .unspecified:
            print("Identificaiton flow is not specified")
        default:
            print("Identificaiton flow is not specified")
        }

        executedStep = .identification
        updateAction(action: .identification)
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
                print("Cannot handle fourthline coordinator nextStepHandler. `self` is not present")
                
                return
            }

            self.bankIDSessionCoordinator?.perform(step: nextStep, self.completionHandler!)
        }
    }

    private func updateAction(action: Action) {
        SessionStorage.updateValue(action.rawValue, for: StoredKeys.initialStep.rawValue)
    }
}
