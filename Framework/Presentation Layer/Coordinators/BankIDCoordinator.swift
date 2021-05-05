//
//  IdentHubSDKCoordinator.swift
//  IdentHubSDK
//

import UIKit

class BankIDCoordinator: BaseCoordinator {

    /// The list of all available actions.
    enum Action {
        case startIdentification
        case phoneVerification
        case bankVerification(step: Action.BankVerification)
        case signDocuments(step: Action.SignDocuments)
        case documentPreview(url: URL)
        case documentExport(url: URL)
        case allDocumentsExport(documents: [URL])
        case finishIdentification
        case pop
        case quit

        enum BankVerification {
            case iban
            case payment
        }

        enum SignDocuments {
            case confirmApplication
            case sign
        }
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

    /// Performs a specified action.
    func perform(action: BankIDCoordinator.Action) {
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
        case .documentPreview(let url):
            displayDocumentPreview(url: url)
        case .documentExport(let url):
            exportDocument(url: url)
        case .allDocumentsExport(let documents):
            exportAllDocuments(documents: documents)
        case .finishIdentification:
            presentFinishIdentification()
            notifyHandlers()
        case .pop:
            pop()
        case .quit:
            quit()
        }
    }

    // MARK: - Coordinator methods -
    override func start(_ completion: @escaping CompletionHandler) {
        perform(action: .startIdentification)
        completionHandler = completion
    }

    // MARK: - Internal methods -
    private func presentStartIdentification() {
        let startIdentificationViewModel = StartIdentificationViewModel(flowCoordinator: self)
        let startIdentificationViewController = StartBankIdentViewController(startIdentificationViewModel)

        presenter.push(startIdentificationViewController, animated: false, completion: nil)
    }

    private func presentPhoneVerification() {
        let phoneVerificationViewController = PhoneVerificationViewController()
        let phoneVerificationViewModel = PhoneVerificationViewModel(flowCoordinator: self, delegate: phoneVerificationViewController, verificationService: appDependencies.verificationService, sessionStorage: appDependencies.sessionInfoProvider, completion: completionHandler!)
        phoneVerificationViewController.viewModel = phoneVerificationViewModel
        presenter.push(phoneVerificationViewController, animated: true, completion: nil)
    }

    private func presentIBANVerification() {
        let ibanVerificationViewController = IBANVerificationViewController()
        let ibanVerificationViewModel = IBANVerificationViewModel(flowCoordinator: self, delegate: ibanVerificationViewController, verificationService: appDependencies.verificationService, sessionStorage: appDependencies.sessionInfoProvider, completion: completionHandler!)
        ibanVerificationViewController.viewModel = ibanVerificationViewModel
        presenter.push(ibanVerificationViewController, animated: true, completion: nil)
    }

    private func presentPaymentVerification() {
        let paymentVerificationViewController = PaymentVerificationViewController()
        let paymentVerificationViewModel = PaymentVerificationViewModel(flowCoordinator: self, delegate: paymentVerificationViewController, verificationService: appDependencies.verificationService, sessionStorage: appDependencies.sessionInfoProvider, completion: completionHandler!)
        paymentVerificationViewController.viewModel = paymentVerificationViewModel
        presenter.push(paymentVerificationViewController, animated: false, completion: nil)
    }

    private func presentConfirmApplication() {
        let confirmApplicationViewController = ConfirmApplicationViewController()
        let confirmApplicationViewModel = ConfirmApplicationViewModel(flowCoordinator: self, delegate: confirmApplicationViewController, verificationService: appDependencies.verificationService)
        confirmApplicationViewController.viewModel = confirmApplicationViewModel
        presenter.push(confirmApplicationViewController, animated: true, completion: nil)
    }

    private func presentSignDocuments() {
        let signDocumentsViewController = SignDocumentsViewController()
        let signDocumentsViewModel = SignDocumentsViewModel(flowCoordinator: self, delegate: signDocumentsViewController, verificationService: appDependencies.verificationService, sessionStorage: appDependencies.sessionInfoProvider, completion: completionHandler!)
        signDocumentsViewController.viewModel = signDocumentsViewModel
        presenter.push(signDocumentsViewController, animated: true, completion: nil)
    }

    private func displayDocumentPreview(url: URL) {
        if let presentController = presenter.navigationController.topViewController {
            documentExporter.previewDocument(from: presentController, documentURL: url)
        }
    }

    private func exportDocument(url: URL) {
        if let presentController = presenter.navigationController.topViewController {
            documentExporter.presentExporter(from: presentController, in: CGRect.zero, documentURL: url)
        }
    }

    private func exportAllDocuments(documents: [URL]) {
        if let presentController = presenter.navigationController.topViewController {
            documentExporter.presentAllDocumentsExporter(from: presentController, documents: documents)
        }
    }

    private func presentFinishIdentification() {
        let finishIdentificationViewController = FinishIdentificationViewController()
        let finishIdentificationViewModel = FinishIdentificationViewModel(flowCoordinator: self, delegate: finishIdentificationViewController, verificationService: appDependencies.verificationService)
        finishIdentificationViewController.viewModel = finishIdentificationViewModel
        presenter.push(finishIdentificationViewController, animated: true, completion: nil)
    }

    private func notifyHandlers() {
        guard let successStatus = self.appDependencies.sessionInfoProvider.isSuccessful, successStatus == true else { return }

        self.completionHandler?(IdentificationSessionResult.success(identification: self.appDependencies.sessionInfoProvider.identificationUID ?? ""))
    }
}
