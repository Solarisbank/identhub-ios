//
//  IdentHubSDKCoordinator.swift
//  IdentHubSDK
//

import UIKit

class BankIDCoordinator: Coordinator {

    /// The list of all available actions.
    enum Action {
        case startIdentification
        case phoneVerification
        case bankVerification(step: Action.BankVerification)
        case signDocuments(step: Action.SignDocuments)
        case documentPreview(data: Data)
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
    private let presenter: Router
    private var completionHandler: CompletionHandler?

    // MARK: - Init methods -
    internal init(appDependencies: AppDependencies, presenter: Router) {
        self.appDependencies = appDependencies
        self.presenter = presenter
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
        case .documentPreview(let data):
            displayDocumentPreview(data: data)
        case .finishIdentification:
            presentFinishIdentification()
        case .pop:
            pop()
        case .quit:
            quit()
        }
    }

    // MARK: - Coordinator methods -
    func start(completion: @escaping CompletionHandler) {
        perform(action: .startIdentification)
        completionHandler = completion
    }

    // MARK: - Internal methods -
    private func presentStartIdentification() {
        let startIdentificationViewController = StartIdentificationViewController()
        let startIdentificationViewModel = StartIdentificationViewModel(flowCoordinator: self)
        startIdentificationViewController.viewModel = startIdentificationViewModel

        presenter.push(startIdentificationViewController, animated: false, completion: nil)
    }

    private func presentPhoneVerification() {
        let phoneVerificationViewController = PhoneVerificationViewController()
        let phoneVerificationViewModel = PhoneVerificationViewModel(flowCoordinator: self, delegate: phoneVerificationViewController, verificationService: appDependencies.verificationService, sessionStorage: appDependencies
                                                                    .sessionInfoProvider)
        phoneVerificationViewController.viewModel = phoneVerificationViewModel
        presenter.push(phoneVerificationViewController, animated: true, completion: nil)
    }

    private func presentIBANVerification() {
        let ibanVerificationViewController = IBANVerificationViewController()
        let ibanVerificationViewModel = IBANVerificationViewModel(flowCoordinator: self, delegate: ibanVerificationViewController, verificationService: appDependencies.verificationService, sessionStorage: appDependencies
                                                                    .sessionInfoProvider)
        ibanVerificationViewController.viewModel = ibanVerificationViewModel
        presenter.push(ibanVerificationViewController, animated: true, completion: nil)
    }

    private func presentPaymentVerification() {
        let paymentVerificationViewController = PaymentVerificationViewController()
        let paymentVerificationViewModel = PaymentVerificationViewModel(flowCoordinator: self, delegate: paymentVerificationViewController, verificationService: appDependencies.verificationService, sessionStorage: appDependencies.sessionInfoProvider)
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
        let signDocumentsViewModel = SignDocumentsViewModel(flowCoordinator: self, delegate: signDocumentsViewController, verificationService: appDependencies.verificationService, sessionStorage: appDependencies.sessionInfoProvider)
        signDocumentsViewController.viewModel = signDocumentsViewModel
        presenter.push(signDocumentsViewController, animated: true, completion: nil)
    }

    private func displayDocumentPreview(data: Data) {
        let documentPreviewViewController = DocumentPreviewViewController(documentData: data)
        presenter.present(documentPreviewViewController, animated: true)
    }

    private func presentFinishIdentification() {
        let finishIdentificationViewController = FinishIdentificationViewController()
        let finishIdentificationViewModel = FinishIdentificationViewModel(flowCoordinator: self, delegate: finishIdentificationViewController, verificationService: appDependencies.verificationService)
        finishIdentificationViewController.viewModel = finishIdentificationViewModel
        presenter.push(finishIdentificationViewController, animated: true, completion: nil)
    }

    private func pop() {
        presenter.pop(animated: true)
    }

    private func quit() {
        let quitPopUpViewController = QuitPopUpViewController()
        quitPopUpViewController.quitAction = {
            self.presenter.dismissModule(animated: false, completion: { [weak self] in
                guard let `self` = self else { return }

                self.presenter.dismissModule(animated: true, completion: {
                    guard let completion = self.completionHandler else { return }

                    completion(IdentificationSessionResult.success(identification: ""))
                })
            })
        }
        quitPopUpViewController.modalPresentationStyle = .overFullScreen
        presenter.present(quitPopUpViewController, animated: false)
    }
}
