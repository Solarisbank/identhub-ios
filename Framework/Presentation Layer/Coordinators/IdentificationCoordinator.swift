//
//  IdentificationCoordinator.swift
//  IdentHubSDK
//

import UIKit

class IdentificationCoordinator: BaseCoordinator {

    /// The list of all available actions.
    enum Action {
        case initialization // Screen with init requests to the server for obtaining init data
        case termsAndConditions // Privacy statement and Terms-Conditions screen
        case identification // Start identification process
        case quit // Quit from identification process
    }

    // MARK: - Properties -
    private let appDependencies: AppDependencies
    private var completionHandler: CompletionHandler?
    private var documentExporter: DocumentExporter = DocumentExporterService()

    // MARK: - Init methods -
    init(appDependencies: AppDependencies, presenter: Router) {

        self.appDependencies = appDependencies

        super.init(presenter: presenter)
    }

    // MARK: - Public methods -

    override func start(_ completion: @escaping CompletionHandler) {
        completionHandler = completion

        perform(action: .initialization)
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
    }

    private func presentPrivacyTermsScreen() {
        let termsVM = TermsViewModel(coordinator: self)
        let termsVC = TermsViewController(termsVM)

        presenter.push(termsVC, animated: false, completion: nil)
    }

    private func startIdentProcess() {

        switch appDependencies.sessionInfoProvider.identificationType {
        case .bank:
            startBankID()
        case .fourthline:
            startFourthline()
        case .idnow:
            print("ID Now identification process start")
        default:
            print("Identification type not defined.")
        }
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
