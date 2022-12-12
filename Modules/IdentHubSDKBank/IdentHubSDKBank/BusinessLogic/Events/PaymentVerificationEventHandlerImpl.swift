//
//  PaymentVerificationEventHandlerImpl.swift
//  IdentHubSDKBank
//

import Foundation
import IdentHubSDKCore
import UIKit

internal enum PaymentVerificationOutput: Equatable {
    case paymentVerified
    case nextStep(step: IdentificationStep) // Method called next step of the identification process
    case failure(APIError)
    case abort
}

internal struct PaymentVerificationInput {
    var identificationStep: IdentificationStep?
}

// MARK: - Payment verification events logic -

typealias PaymentVerificationCallback = (PaymentVerificationOutput) -> Void

final internal class PaymentVerificationEventHandlerImpl<ViewController: UpdateableShowable>: EventHandler where ViewController.EventHandler == AnyEventHandler<PaymentVerificationEvent>, ViewController.ViewState == PaymentVerificationState {
    
    weak var updateView: ViewController?
    weak var callbackView: ViewController?
    
    private let verificationService: VerificationService
    private let alertsService: AlertsService
    private var state: PaymentVerificationState
    private var input: PaymentVerificationInput
    private var callback: PaymentVerificationCallback
    
    private var storage: Storage
    
    private var nextStep: IdentificationStep = .unspecified
    private var timer: Timer?
        
    enum Constants {
        static var identificationStatusCheckInterval: TimeInterval { 3.0 }
    }
    
    init(
        verificationService: VerificationService,
        alertsService: AlertsService,
        input: PaymentVerificationInput,
        storage: Storage,
        callback: @escaping PaymentVerificationCallback
    ) {
        self.verificationService = verificationService
        self.alertsService = alertsService
        self.input = input
        self.storage = storage
        self.callback = callback
        self.state = PaymentVerificationState()
    }
    
    func handleEvent(_ event: PaymentVerificationEvent) {
        switch event {
        case .assemblyURLRequest:
            assemblyURLRequest()
        case .checkIdentificationStatus:
            checkIdentificationStatus()
        case .executeStep:
            executeStep()
        case .quit:
            quit()
        }
    }
    
    deinit {
        bankLog.info("timer?.invalidate()")
        timer?.invalidate()
    }
    
    func assemblyURLRequest() {
        updateState { state in
            state.state = .establishingConnection
        }
        guard let path = storage[.identificationPath],
              let url = URL(string: path) else {
            updateState { state in
                state.state = .failed
            }
            callback(.failure(.requestError))
            return
        }
        let urlRequest = URLRequest(url: url)
        DispatchQueue.main.asyncAfter(deadline: 1.seconds.fromNow) { [weak self] in
            guard let `self` = self else { return }
            self.updateState { state in
                state.state = .paymentInitiation
                state.urlRequest = urlRequest
            }
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: Constants.identificationStatusCheckInterval, repeats: true, block: { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.checkIdentificationStatus()
        })
    }
    
    func checkIdentificationStatus() {
        guard let identificationUID = storage[.identificationUID] else {
            callback(.failure(.requestError))
            return
        }
        bankLog.info("check Identification Status")
        verificationService.getIdentification(for: identificationUID) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let response):
                self.defineNextStep(response)
                
                switch response.status {
                case .authorizationRequired,
                        .identificationRequired:
                    DispatchQueue.main.async {
                        self.timer?.invalidate()
                        self.updateState { state in
                            state.state = .processingVerification
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: 1.seconds.fromNow) {
                        self.updateState { state in
                            state.state = .success
                        }
                    }
                case .failed:
                    if self.nextStep != .unspecified {
                        DispatchQueue.main.async {
                            self.timer?.invalidate()
                            self.executeStep()
                        }
                    } else {
                        self.interruptProcess()
                    }
                default:
                    print("Status not processed in SDK: \(response.status.rawValue)")
                }
            case .failure(let error):
                self.callback(.failure(error.apiError))
            }
        }
    }
    
    func executeStep() {
        if nextStep != .unspecified {
            self.callback(.nextStep(step: nextStep))
        } else {
            self.callback(.paymentVerified)
        }
    }
    
    private func defineNextStep(_ response: Identification) {
        if let step = response.nextStep, let nextStep = IdentificationStep(rawValue: step) {
            self.nextStep = nextStep
        } else if let step = response.fallbackStep, let fallbackStep = IdentificationStep(rawValue: step) {
            self.nextStep = fallbackStep
        } else {
            self.nextStep = .unspecified
        }
    }
    
    private func interruptProcess() {
        DispatchQueue.main.async {
            self.callback(.failure(.paymentFailed))
        }
    }
    
    private func updateState(_ update: @escaping (inout PaymentVerificationState) -> Void) {
        DispatchQueue.main.async {
            update(&self.state)
            self.updateView?.updateView(self.state)
        }
    }
    
    func quit() {
        callback(.abort)
    }
}
