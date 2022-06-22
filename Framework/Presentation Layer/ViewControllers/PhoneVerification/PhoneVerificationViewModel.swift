//
//  PhoneVerificationViewModel.swift
//  IdentHubSDK
//

import Foundation

/// ViewModel which supports phone verification view controller.
final internal class PhoneVerificationViewModel: NSObject, ViewModel {

    /// Delegate which informs about the current state of the performed action.
    weak var delegate: PhoneVerificationViewModelDelegate?

    weak var flowCoordinator: BankIDCoordinator?

    var verificationService: VerificationService

    var completionHandler: CompletionHandler

    private let sessionStorage: StorageSessionInfoProvider
    private var requestTimer: Timer?
    private var counts = 20

    init(flowCoordinator: BankIDCoordinator, verificationService: VerificationService, sessionStorage: StorageSessionInfoProvider, completion: @escaping CompletionHandler) {
        self.flowCoordinator = flowCoordinator
        self.verificationService = verificationService
        self.sessionStorage = sessionStorage
        self.completionHandler = completion
        super.init()
    }

    // MARK: Methods

    /// Submit code.
    func submitCode(_ code: String?) {
        guard let code = code else { return }
        expireTimer()
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
                    self.completionHandler(.failure(.authorizationFailed))
                }
            case .failure(let error):
                self.fail()
                self.completionHandler(.failure(error.apiError))
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
                self.sessionStorage.mobileNumber = response.number
                DispatchQueue.main.async {
                    self.delegate?.didGetPhoneNumber(response.number.withStarFormat())
                }
            case .failure:
                DispatchQueue.main.async {
                    self.delegate?.didGetPhoneNumber(nil)
                }
            }
        }
        delegate?.willGetNewCode()
        setupTimer()
    }

    /// Begin bank identification process.
    func beginBankIdentification() {
        flowCoordinator?.perform(action: .bankVerification(step: .iban))
    }
}

// MARK: - Internal methods -

private extension PhoneVerificationViewModel {
    
    private func setupTimer() {
        requestTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        counts = 20
        delegate?.didUpdateTimerLabel(String(describing: counts))
    }
    
    private func expireTimer() {
        requestTimer?.invalidate()
        delegate?.didEndTimerDelay()
    }
    
    private func fail() {
        DispatchQueue.main.async {
            self.delegate?.verificationFailed()
            self.expireTimer()
        }
    }
    
    @objc private func updateTimer() {
        counts -= 1
        if counts >= 1 {
            let secondString = (counts >= 10) ? String(describing: counts) : "0\(String(describing: counts))"
            delegate?.didUpdateTimerLabel(secondString)
        } else {
            expireTimer()
        }
    }
}

protocol PhoneVerificationViewModelDelegate: VerifiableViewModelDelegate {

    /// Called when the phone number has been fetched.
    ///
    /// - Parameter phoneNumber: Current client phone number.
    func didGetPhoneNumber(_ phoneNumber: String?)

    /// Called when new code is about to be received.
    func willGetNewCode()
    
    /// Method notified when timer expired.
    /// Display send new code request
    func didEndTimerDelay()
    
    /// Method updated count down timer label
    /// count - number of seconds
    func didUpdateTimerLabel(_ count: String)
}
