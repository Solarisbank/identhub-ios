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

    private let sessionStorage: StorageSessionInfoProvider

    init(flowCoordinator: BankIDCoordinator, delegate: PhoneVerificationViewModelDelegate, verificationService: VerificationService, sessionStorage: StorageSessionInfoProvider) {
        self.flowCoordinator = flowCoordinator
        self.delegate = delegate
        self.verificationService = verificationService
        self.sessionStorage = sessionStorage
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
            switch result {
            case .success(let response):
                if response.verified {
                    DispatchQueue.main.async {
                        self?.delegate?.verificationSucceeded()
                    }
                } else {
                    self?.fail()
                }
            case .failure(_):
                self?.fail()
            }
        }
    }

    /// Request new code.
    /// Sends new sms message with TAN.
    func requestNewCode() {
        verificationService.authorizeMobileNumber { [weak self] result in
            switch result {
            case .success(let response):
                if response.verified {
                    let mobileNumber = response.number
                    self?.sessionStorage.mobileNumber = mobileNumber
                    DispatchQueue.main.async {
                        self?.delegate?.didGetPhoneNumber(response.number)
                    }
                }
            default:
                break
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
