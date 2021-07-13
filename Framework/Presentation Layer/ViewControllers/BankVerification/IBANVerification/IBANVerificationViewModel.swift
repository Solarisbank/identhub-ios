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

    private var retriesCount: Int = 0

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

    /// Method starts user's IBAN value validation
    /// - Parameter iban: string of IBAN
    func initiatePaymentVerification(withIBAN iban: String?) {
        let isIBANValid = validateIBAN(iban)
        delegate?.isIBANFormatValid(isIBANValid)
        guard isIBANValid,
              let iban = iban else { completionHandler(.failure(APIError.requestError)); return }
        verifyIBAN(iban)
    }

    /// Perform alternate flow of user validation
    func performFallbackIdent() {

        if let fallback = sessionStorage.fallbackIdentificationStep {
            flowCoordinator.perform(action: .nextStep(step: fallback))
        }
    }

    /// Present identification session quit popup
    func didTriggerQuit() {
        completionHandler(.failure(.ibanVerfificationFailed))
        flowCoordinator.perform(action: .close)
    }

    /// Method defines if exist fallback identificaiton option for user
    /// - Returns: bool value of step existance
    func isExistFallbackOption() -> Bool {
        return ( sessionStorage.fallbackIdentificationStep != nil )
    }
}

// MARK: - Private methods -

private extension IBANVerificationViewModel {

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
                    if let step = response.nextStep, let nextStep = IdentificationStep(rawValue: step) {
                        self.flowCoordinator.perform(action: .nextStep(step: nextStep))
                    } else {
                        self.flowCoordinator.perform(action: .bankVerification(step: .payment))
                    }
                }
            case .failure(let error):
                self.processedFailure(with: error)
            }
        }
    }

    private func processedFailure(with error: APIError) {

        switch error {
        case .clientError(let error):
            if error?.code == .mobileNotVerified {

               DispatchQueue.main.async {
                   self.flowCoordinator.perform(action: .phoneVerification)
               }
               return
            }
            retriesCount += 1
        case .incorrectIdentificationStatus(let error):
            print("IBAN verification error: \(String(describing: error?.detail))")
            retriesCount += 1
        default:
            completionHandler(.failure(error))
        }

        let allowRetry = ( retriesCount < sessionStorage.retries )

        DispatchQueue.main.async {
            self.delegate?.verificationIBANFailed(error, allowRetry: allowRetry)
        }
    }
}

protocol IBANVerificationViewModelDelegate: AnyObject {

    /// Called after IBAN was entered to confirm if its format matches the standards.
    func isIBANFormatValid(_ valid: Bool)

    /// Called if IBAN verification failed
    /// - Parameter error: failed reason
    /// - Parameter allowRetry: inform if user can try another IBAN or has to start with alternate identification method
    func verificationIBANFailed(_ error: APIError, allowRetry: Bool)
}
