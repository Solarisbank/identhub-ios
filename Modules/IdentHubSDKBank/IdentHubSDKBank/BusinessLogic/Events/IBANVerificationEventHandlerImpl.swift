//
//  BankEventHandlerImpl.swift
//  Bank
//

import Foundation
import IdentHubSDKCore
import UIKit

internal enum IBANVerificationOutput: Equatable {
    case ibanVerified
    case nextStep(step: IdentificationStep) // Method called next step of the identification process
    case failure(APIError)
    case abort
}

internal struct IBANVerificationInput {
    var identificationStep: IdentificationStep?
}

// MARK: - IBAN verification events logic -

typealias IBANVerificationCallback = (IBANVerificationOutput) -> Void

final internal class IBANVerificationEventHandlerImpl<ViewController: UpdateableShowable>: EventHandler where ViewController.EventHandler == AnyEventHandler<IBANVerificationEvent>, ViewController.ViewState == IBANVerificationState {
    
    weak var updateView: ViewController? 
    weak var callbackView: ViewController?
    
    private let verificationService: VerificationService
    private let alertsService: AlertsService
    private var state: IBANVerificationState
    private var input: IBANVerificationInput
    private var callback: IBANVerificationCallback
    
    private var storage: Storage
    
    private var retriesCount: Int = 0

    init(
        verificationService: VerificationService,
        alertsService: AlertsService,
        input: IBANVerificationInput,
        storage: Storage,
        callback: @escaping IBANVerificationCallback
    ) {
        self.verificationService = verificationService
        self.alertsService = alertsService
        self.input = input
        self.storage = storage
        self.callback = callback
        self.state = IBANVerificationState()
    }

    func handleEvent(_ event: IBANVerificationEvent) {
        switch event {
        case .verifyIBAN(iban: let iban):
            initiatePaymentVerification(iban: iban)
        case .validateEnteredIBAN(iban: let iban):
            let value = validateIBAN(iban)
            self.updateState { state in
                state.state = .textFieldState
                state.isIBANFormatValid = value
            }
        case .quit:
            quit()
        }
    }
    
    /// Method starts user's IBAN value validation
    /// - Parameter iban: string of IBAN
    func initiatePaymentVerification(iban: String?) {
        let isIBANValid = validateIBAN(iban)
        self.updateState { state in
            state.state = .isIBANFormatValid
            state.isIBANFormatValid = isIBANValid
        }
        guard isIBANValid,
                let iban = iban else { return }
        verifyIBAN(iban)
    }
    
    private func validateIBAN(_ iban: String?) -> Bool {
        guard let iban = iban else { return false }
        return iban.matches(.IBANRegex)
    }
    
    private func verifyIBAN(_ iban: String) {
        bankLog.info("verify IBAN")
        
        verificationService.verifyIBAN(iban, input.identificationStep ?? .unspecified) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                self.storage[.identificationUID] = response.id
                self.storage[.identificationPath] = response.url
                DispatchQueue.main.async {
                    if let step = response.nextStep, let nextStep = IdentificationStep(rawValue: step) {
                        self.callback(.nextStep(step: nextStep))
                    } else {
                        self.callback(.ibanVerified)
                    }
                }
            case .failure(let error):
                bankLog.warn("IBAN failure")
                self.processedFailure(with: error)
            }
        }
    }
    
    private func processedFailure(with error: ResponseError) {
        switch error.apiError {
        case .clientError(let detail),
             .incorrectIdentificationStatus(let detail):
            retriesCount += 1
            if retriesCount < storage[.retriesCount] ?? 0 {
                if detail?.nextStep != nil || detail?.fallbackStep != nil {
                    DispatchQueue.main.async {
                        self.verificationIBANFailed(error)
                    }
                } else {
                    didTriggerQuit()
                }
            } else {
                didTriggerQuit()
            }
        default:
            self.callback(.failure(error.apiError))
        }
    }
    
    func verificationIBANFailed(_ error: ResponseError) {
        var errorDetail: ErrorDetail?
        var message = ""
        
        switch error.apiError {
        case .clientError(let detail),
             .incorrectIdentificationStatus(let detail):
            message = Localizable.BankVerification.IBANVerification.notValidIBAN
            errorDetail = detail
        default:
            message = error.apiError.text()
        }
        
        #if ENV_DEBUG
        message += "\n\(error.detailDescription)"
        #endif
        
        showVerificationError(message, error: errorDetail)
        self.updateState { state in
            state.state = .isIBANFormatValid
            state.isIBANFormatValid = false
        }
    }

    private func updateState(_ update: @escaping (inout IBANVerificationState) -> Void) {
        DispatchQueue.main.async {
            update(&self.state)
            self.updateView?.updateView(self.state)
        }
    }

    func quit() {
        callback(.abort)
    }
    
    func didTriggerQuit() {
        DispatchQueue.main.async {[weak self] in
            self?.callback(.failure(.ibanVerfificationFailed))
        }
    }
    
    private func showVerificationError(_ message: String?, error: ErrorDetail? = nil) {
        let alert = UIAlertController(title: Localizable.BankVerification.IBANVerification.failureAlertTitle, message: message, preferredStyle: .alert)

        if let errorDetail = error, let nextStep = errorDetail.nextStep {
            let reactionAction = UIAlertAction(title: Localizable.BankVerification.IBANVerification.retryOption, style: .default, handler: { [weak self] _ in
                self?.performFlowStep(nextStep)
            })
            alert.addAction(reactionAction)
        }

        if let errorDetail = error, let fallbackStep = errorDetail.fallbackStep, fallbackStep != .abort {
            let fallbackAction = UIAlertAction(title: Localizable.BankVerification.IBANVerification.alternateOption, style: .default, handler: { [weak self] _ in
                self?.performFlowStep(fallbackStep)
            })
            alert.addAction(fallbackAction)
            
        } else if isExistFallbackOption() {
            let fallbackAction = UIAlertAction(title: Localizable.BankVerification.IBANVerification.alternateOption, style: .default, handler: { [weak self] _ in
                self?.performFallbackIdent()
            })
            alert.addAction(fallbackAction)
        }

        let cancelAction = UIAlertAction(title: Localizable.Common.quit, style: .cancel, handler: { [weak self] _ in
            self?.didTriggerQuit()
        })

        alert.addAction(cancelAction)
        alertsService.presentCustomAlert(alert: alert)
        
        self.updateState { state in
            state.state = .error
            state.error = message ?? ""
        }
    }
    
    /// Perform alternative step of user validation
    func performFlowStep(_ step: IdentificationStep) {
        self.callback(.nextStep(step: step))
    }

    /// Perform alternate flow of user validation
    func performFallbackIdent() {
        guard let fallbackStep = storage[.fallbackIdentStep] else {
            return
        }
        self.callback(.nextStep(step: fallbackStep))
    }
    
    /// Method defines if exist fallback identificaiton option for user
    /// - Returns: bool value of step existance
    func isExistFallbackOption() -> Bool {
        return ( storage[.fallbackIdentStep] != nil )
    }
        
}
