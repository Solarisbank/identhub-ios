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

    init(flowCoordinator: BankIDCoordinator, delegate: IBANVerificationViewModelDelegate, verificationService: VerificationService, sessionStorage: StorageSessionInfoProvider) {
        self.flowCoordinator = flowCoordinator
        self.delegate = delegate
        self.verificationService = verificationService
        self.sessionStorage = sessionStorage
        super.init()
    }

    // MARK: Methods

    func initiatePaymentVerification(withIBAN iban: String?) {
        let isIBANValid = validateIBAN(iban)
        delegate?.isIBANFormatValid(isIBANValid)
        guard isIBANValid,
              let iban = iban else { return }
        verifyIBAN(iban)
    }

    // MARK: Private properties

    private func validateIBAN(_ iban: String?) -> Bool {
        guard let iban = iban else { return false }
        return iban.matches(.IBANRegex)
    }

    private func verifyIBAN(_ iban: String) {
        verificationService.verifyIBAN(iban) { [weak self] result in
            switch result {
            case .success(let response):
                self?.sessionStorage.identificationUID = response.id
                self?.sessionStorage.identificationPath = response.url
                DispatchQueue.main.async {
                    self?.flowCoordinator.perform(action: .bankVerification(step: .payment))
                }
            case .failure(_):
                break
            }
        }
    }
}

protocol IBANVerificationViewModelDelegate: AnyObject {

    /// Called after IBAN was entered to confirm if its format matches the standards.
    func isIBANFormatValid(_ valid: Bool)
}
