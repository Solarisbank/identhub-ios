//
//  IBANVerificationViewModel.swift
//  IdentHubSDK
//

import Foundation

/// ViewModel which supports IBAN view controller.
final internal class IBANVerificationViewModel: NSObject {

    /// Delegate which informs about the current state of the performed action.
    weak var delegate: IBANVerificationViewModelDelegate?

    private let flowCoordinator: BankIDCoordinator

    private let verificationService: VerificationService

    private let sessionStorage: StorageSessionInfoProvider

    private var completionHandler: CompletionHandler

    init(flowCoordinator: BankIDCoordinator, delegate: IBANVerificationViewModelDelegate, verificationService: VerificationService, sessionStorage: StorageSessionInfoProvider, completion: @escaping CompletionHandler) {
        self.flowCoordinator = flowCoordinator
        self.delegate = delegate
        self.verificationService = verificationService
        self.sessionStorage = sessionStorage
        self.completionHandler = completion
        super.init()
    }

    // MARK: Methods

    func initiatePaymentVerification(withIBAN iban: String?) {
        let isIBANValid = validateIBAN(iban)
        delegate?.isIBANFormatValid(isIBANValid)
        guard isIBANValid,
              let iban = iban else { completionHandler(.failure(APIError.clientError)); return }
        verifyIBAN(iban)
    }

    // MARK: Private properties

    private func validateIBAN(_ iban: String?) -> Bool {
        guard let iban = iban else { return false }
        return iban.matches(.IBANRegex)
    }

    private func verifyIBAN(_ iban: String) {
        verificationService.verifyIBAN(iban) { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .success(let response):
                self.sessionStorage.identificationUID = response.id
                self.sessionStorage.identificationPath = response.url
                DispatchQueue.main.async {
                    if let step = response.nextStep {
                        self.flowCoordinator.perform(action: .nextStep(step: IdentificationStep(rawValue: step) ?? .unspecified))
                    } else {
                        self.flowCoordinator.perform(action: .bankVerification(step: .payment))
                    }
                }
            case .failure(let error):
                if error == .clientError {
                    DispatchQueue.main.async {
                        self.flowCoordinator.perform(action: .nextStep(step: .mobileNumber))
                    }
                }
                self.completionHandler(.failure(error))
            }
        }
    }
}

protocol IBANVerificationViewModelDelegate: AnyObject {

    /// Called after IBAN was entered to confirm if its format matches the standards.
    func isIBANFormatValid(_ valid: Bool)
}
