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

    init(flowCoordinator: BankIDCoordinator, verificationService: VerificationService, sessionStorage: StorageSessionInfoProvider, completion: @escaping CompletionHandler) {
        self.flowCoordinator = flowCoordinator
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

    /// Perform alternative step of user validation
    func performFlowStep(_ step: IdentificationStep) {
        self.flowCoordinator.perform(action: .nextStep(step: step))
    }

    /// Perform alternate flow of user validation
    func performFallbackIdent() {

        if let fallback = sessionStorage.fallbackIdentificationStep {
            flowCoordinator.perform(action: .nextStep(step: fallback))
        }
    }

    /// Present identification session quit popup
    func didTriggerQuit() {
        DispatchQueue.main.async {[weak self] in
            self?.completionHandler(.failure(.ibanVerfificationFailed))
            self?.flowCoordinator.perform(action: .close)
        }
    }

    /// Method defines if exist fallback identificaiton option for user
    /// - Returns: bool value of step existance
    func isExistFallbackOption() -> Bool {
        return ( sessionStorage.fallbackIdentificationStep != nil )
    }

    /// Method validates entered user IBAN value
    /// - Parameter iban: string of the IBAN value
    /// - Returns: validation status
    func validateEnteredIBAN(withIBAN iban: String?) -> Bool {
        return validateIBAN(iban)
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

    private func processedFailure(with error: ResponseError) {

        switch error.apiError {
        case .clientError(let detail),
             .incorrectIdentificationStatus(let detail):
            retriesCount += 1

            if retriesCount < sessionStorage.retries {
               if let _ = detail?.nextStep, let _ = detail?.fallbackStep {
                    DispatchQueue.main.async {
                        self.delegate?.verificationIBANFailed(error)
                    }
               } else if let nextStep = detail?.nextStep {
                   self.performFlowStep(nextStep)
               } else {
                   didTriggerQuit()
               }
            } else {
                didTriggerQuit()
            }
        default:
            completionHandler(.failure(error.apiError))
        }
    }
}

protocol IBANVerificationViewModelDelegate: AnyObject {

    /// Called after IBAN was entered to confirm if its format matches the standards.
    func isIBANFormatValid(_ valid: Bool)

    /// Called if IBAN verification failed
    /// - Parameter error: failed reason
    /// - Parameter code: string value of the response error code
    func verificationIBANFailed(_ error: ResponseError)
}
