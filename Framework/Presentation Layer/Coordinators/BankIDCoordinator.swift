//
//  IdentHubSDKCoordinator.swift
//  IdentHubSDK
//

import UIKit

class BankIDCoordinator: BaseCoordinator {

    // MARK: - Properties -
    private let appDependencies: AppDependencies
    private var identificationStep: BankIDStep = .startIdentification
    private var completionHandler: CompletionHandler?
    private var documentExporter: DocumentExporter = DocumentExporterService()

    // MARK: - Init methods -
    init(appDependencies: AppDependencies, presenter: Router) {

        self.appDependencies = appDependencies

        super.init(presenter: presenter)

        restoreStep()
    }

    // MARK: - Public methods -

    /// Performs a specified action.
    func perform(action: BankIDStep) {
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
        case .nextStep(let step):
            perfomIdentStep(step: step)
        case .pop:
            pop()
        case .quit:
            quit()
        case .close:
            close()
        }
    }

    // MARK: - Coordinator methods -
    override func start(_ completion: @escaping CompletionHandler) {
        completionHandler = completion
        perform(action: identificationStep)
    }
}

// MARK: - Save / load ident data -

private extension BankIDCoordinator {

    private func restoreStep() {
        guard let restoreData = SessionStorage.obtainValue(for: StoredKeys.bankIDStep.rawValue) as? Data else {

            if let identStep = appDependencies.sessionInfoProvider.identificationStep {
                identificationStep = .nextStep(step: identStep)
            }
            return
        }

        do {
            let step = try JSONDecoder().decode(BankIDStep.self, from: restoreData)
            identificationStep = step
            KYCContainer.shared.restoreData(appDependencies.sessionInfoProvider)
        } catch {
            print("Stored bank id step data decoding failed: \(error.localizedDescription).\nIdentification process would be started from beginning")
        }
    }

    private func updateBankIDStep(step: BankIDStep) {
        do {
            let stepData = try JSONEncoder().encode(step)
            SessionStorage.updateValue(stepData, for: StoredKeys.bankIDStep.rawValue)
        } catch {
            print("Coding bank id step data failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Navigation methods -

private extension BankIDCoordinator {

    private func perfomIdentStep(step: IdentificationStep) {

        switch step {
        case .mobileNumber:
            presentPhoneVerification()
        case .bankIBAN,
             .bankIDIBAN:
            presentIBANVerification()
        case .bankIDFourthline:
            presentFourthlineFlow()
        case .bankQES,
             .bankIDQUES:
            presentSignDocuments()
        case .fourthline:
            presentFourthlineFlow()
        case .unspecified:
            print("Step is not supported or not specified yet")
        }
    }

    private func presentStartIdentification() {
        let startIdentificationViewModel = StartIdentificationViewModel(flowCoordinator: self)
        let startIdentificationViewController = StartBankIdentViewController(startIdentificationViewModel)

        presenter.push(startIdentificationViewController, animated: false, completion: nil)
        updateBankIDStep(step: .startIdentification)
    }

    private func presentPhoneVerification() {
        let phoneVerificationViewController = PhoneVerificationViewController()
        let phoneVerificationViewModel = PhoneVerificationViewModel(flowCoordinator: self, delegate: phoneVerificationViewController, verificationService: appDependencies.verificationService, sessionStorage: appDependencies.sessionInfoProvider, completion: completionHandler!)
        phoneVerificationViewController.viewModel = phoneVerificationViewModel
        presenter.push(phoneVerificationViewController, animated: true, completion: nil)
        updateBankIDStep(step: .phoneVerification)
    }

    private func presentIBANVerification() {
        let ibanVerificationViewController = IBANVerificationViewController()
        let ibanVerificationViewModel = IBANVerificationViewModel(flowCoordinator: self, delegate: ibanVerificationViewController, verificationService: appDependencies.verificationService, sessionStorage: appDependencies.sessionInfoProvider, completion: completionHandler!)
        ibanVerificationViewController.viewModel = ibanVerificationViewModel
        presenter.push(ibanVerificationViewController, animated: true, completion: nil)
        updateBankIDStep(step: .bankVerification(step: .iban))
    }

    private func presentPaymentVerification() {
        let paymentVerificationViewController = PaymentVerificationViewController()
        let paymentVerificationViewModel = PaymentVerificationViewModel(flowCoordinator: self, delegate: paymentVerificationViewController, verificationService: appDependencies.verificationService, sessionStorage: appDependencies.sessionInfoProvider, completion: completionHandler!)
        paymentVerificationViewController.viewModel = paymentVerificationViewModel
        presenter.push(paymentVerificationViewController, animated: false, completion: nil)
        updateBankIDStep(step: .bankVerification(step: .payment))
    }

    private func presentConfirmApplication() {
        let confirmApplicationViewController = ConfirmApplicationViewController()
        let confirmApplicationViewModel = ConfirmApplicationViewModel(flowCoordinator: self, delegate: confirmApplicationViewController, verificationService: appDependencies.verificationService)
        confirmApplicationViewController.viewModel = confirmApplicationViewModel
        presenter.push(confirmApplicationViewController, animated: true, completion: nil)
        updateBankIDStep(step: .signDocuments(step: .confirmApplication))
    }

    private func presentSignDocuments() {
        let signDocumentsViewController = SignDocumentsViewController()
        let signDocumentsViewModel = SignDocumentsViewModel(flowCoordinator: self, delegate: signDocumentsViewController, verificationService: appDependencies.verificationService, sessionStorage: appDependencies.sessionInfoProvider, completion: completionHandler!)
        signDocumentsViewController.viewModel = signDocumentsViewModel
        presenter.push(signDocumentsViewController, animated: true, completion: nil)
        updateBankIDStep(step: .signDocuments(step: .sign))
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
        updateBankIDStep(step: .finishIdentification)
    }

    private func notifyHandlers() {
        guard let successStatus = self.appDependencies.sessionInfoProvider.isSuccessful, successStatus == true else { return }

        self.completionHandler?(IdentificationSessionResult.success(identification: self.appDependencies.sessionInfoProvider.identificationUID ?? ""))
    }

    private func presentFourthlineFlow() {
        let fourthlineCoordinator = FourthlineIdentCoordinator(appDependencies: appDependencies, presenter: presenter)

        fourthlineCoordinator.start { result in

            switch result {
            case .success( _ ):
                self.presentSignDocuments()
            case .failure( _ ):
                self.completionHandler?(result)
            }
        }
    }
}
