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
    }

    // MARK: - Properties -
    private let appDependencies: AppDependencies
    private var completionHandler: CompletionHandler?
    private var documentExporter: DocumentExporter = DocumentExporterService()
    private var executedStep: Action? {
        didSet {
            SessionStorage.updateValue(executedStep?.rawValue ?? Action.initialization.rawValue, for: StoredKeys.initialStep.rawValue)
        }
    }
    private var identificationMethod: IdentificationStep? {
        didSet {
            SessionStorage.updateValue(identificationMethod?.rawValue ?? IdentificationStep.unspecified.rawValue, for: StoredKeys.identMethod.rawValue)
        }
    }

    // MARK: - Init methods -
    init(appDependencies: AppDependencies, presenter: Router) {

        self.appDependencies = appDependencies

        super.init(presenter: presenter)
    }

    // MARK: - Public methods -

    override func start(_ completion: @escaping CompletionHandler) {
        completionHandler = completion

        if let step = SessionStorage.obtainValue(for: StoredKeys.initialStep.rawValue) as? Int {
            executedStep = Action(rawValue: step)
        }

        perform(action: executedStep ?? .initialization)
    }

    func perform(action: IdentificationCoordinator.Action) {

        switch action {
        case .initialization:
            presentInitialScreen()
        case .termsAndConditions:
            presentPrivacyTermsScreen()
        case .identification:
            startIdentProcess()
        case .quit:
            quit()
        }
    }
}

// MARK: - Manager Session Tracker methods -

private extension IdentificationCoordinator {

    private func presentInitialScreen() {
        let requestVM = RequestsViewModel(appDependencies.verificationService, storage: appDependencies.sessionInfoProvider, type: .initateFlow, identCoordinator: self)
        let requestVC = RequestsViewController(requestVM)

        presenter.push(requestVC, animated: true, completion: nil)
        executedStep = .initialization
    }

    private func presentPrivacyTermsScreen() {
        let termsVM = TermsViewModel(coordinator: self)
        let termsVC = TermsViewController(termsVM)

        presenter.push(termsVC, animated: false, completion: nil)
        executedStep = .termsAndConditions
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
        case .fourthline:
            startFourthline()
        case .unspecified:
            print("Identificaiton flow is not specified")
        default:
            print("Identificaiton flow is not specified")
        }

        executedStep = .identification
    }

    private func startBankID() {
        let bankIDSessionCoordinator = BankIDCoordinator(appDependencies: appDependencies, presenter: presenter)

        bankIDSessionCoordinator.start(completionHandler!)
    }

    private func startFourthline() {
        let fourthlineCoordinator = FourthlineIdentCoordinator(appDependencies: appDependencies, presenter: presenter)

        fourthlineCoordinator.start(completionHandler!)
    }
}
