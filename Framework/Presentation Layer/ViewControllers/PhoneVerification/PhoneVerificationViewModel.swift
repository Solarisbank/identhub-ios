//
//  PhoneVerificationViewModel.swift
//  IdentHubSDK
//

import Foundation

/// ViewModel which supports phone verification view controller.
final internal class PhoneVerificationViewModel: NSObject, ViewModel {

    /// Delegate which informs about the current state of the performed action.
    weak var delegate: PhoneVerificationViewModelDelegate?

    var flowCoordinator: BankIDCoordinator

    var verificationService: VerificationService

    var completionHandler: CompletionHandler

    private let sessionStorage: StorageSessionInfoProvider

    init(flowCoordinator: BankIDCoordinator, delegate: PhoneVerificationViewModelDelegate, verificationService: VerificationService, sessionStorage: StorageSessionInfoProvider, completion: @escaping CompletionHandler) {
        self.flowCoordinator = flowCoordinator
        self.delegate = delegate
        self.verificationService = verificationService
        self.sessionStorage = sessionStorage
        self.completionHandler = completion
        super.init()
        requestNewCode()
    }

    private func fail() {
        DispatchQueue.main.async {
            self.delegate?.verificationFailed()
        }
    }

    // MARK: Methods

    /// Submit code.
    func submitCode(_ code: String?) {
        guard let code = code else { return }
        delegate?.verificationStarted()
        verificationService.verifyMobileNumberTAN(token: code) { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .success(let response):
                if response.verified {
                    self.sessionStorage.phoneVerified = true
                    DispatchQueue.main.async {
                        self.delegate?.verificationSucceeded()
                    }
                } else {
                    self.fail()
                    self.completionHandler(.failure)
                }
            case .failure(_):
                self.fail()
                self.completionHandler(.failure)
            }
        }
    }

    /// Request new code.
    /// Sends new sms message with TAN.
    func requestNewCode() {
        verificationService.authorizeMobileNumber { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .success(let response):
                if response.verified {
                    let mobileNumber = response.number
                    self.sessionStorage.mobileNumber = mobileNumber
                    DispatchQueue.main.async {
                        self.delegate?.didGetPhoneNumber(response.number)
                    }
                }
            case .failure(_):
                self.completionHandler(.failure)
            }
        }
        delegate?.willGetNewCode()
    }

    /// Begin bank identification process.
    func beginBankIdentification() {
        flowCoordinator.perform(action: .bankVerification(step: .iban))
    }
}

protocol PhoneVerificationViewModelDelegate: VerifiableViewModelDelegate {

    /// Called when the phone number has been fetched.
    ///
    /// - Parameter phoneNumber: Current client phone number.
    func didGetPhoneNumber(_ phoneNumber: String)

    /// Called when new code is about to be received.
    func willGetNewCode()
}
