//
//  PhoneApplicationEventHandlerImpl.swift
//  IdentHubSDKCore
//

import Foundation
import UIKit

internal enum PhoneVerificationOutput: Equatable {
    case phoneVerified
    case abort
}

internal struct PhoneVerificationInput {
    var identificationStep: IdentificationStep?
}

// MARK: - PhoneVerification events logic -

typealias PhoneVerificationCallback = (Result<PhoneVerificationOutput, APIError>) -> Void

final class PhoneVerificationEventHandlerImpl<ViewController: UpdateableShowable>: EventHandler where ViewController.EventHandler == AnyEventHandler<PhoneVerificationEvent>, ViewController.ViewState == PhoneVerificationState {
    
    enum Constants {
        static var updateTimerInterval: TimeInterval { 1.0 }
    }
    
    weak var updateView: ViewController?
    
    private let verificationService: VerificationService
    private var state: PhoneVerificationState
    private var storage: Storage
    private var callback: PhoneVerificationCallback
    
    let sessionInfoProvider: StorageSessionInfoProvider
    
    private var requestTimer: Timer?
    private var counts = 20
    
    init(
        verificationService: VerificationService,
        storage: Storage,
        session: StorageSessionInfoProvider,
        callback: @escaping PhoneVerificationCallback
    ) {
        self.verificationService = verificationService
        self.storage = storage
        self.callback = callback
        self.state = PhoneVerificationState()
        self.sessionInfoProvider = session
    }
    
    deinit {
        requestTimer?.invalidate()
    }
    
    func handleEvent(_ event: PhoneVerificationEvent) {
        switch event {
        case .requestNewCode:
            requestNewCode()
        case .submitCode(let code):
            submitCode(code: code)
        case .verificationSuccess:
            beginBankIdentification()
        case .quit:
            quit()
        }
    }
    
    func requestNewCode() {
        verificationService.authorizeMobileNumber() { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let response):
                self.storage[.mobileNumber] = response.number
                let mobileNumber = response.number
                self.updateState { state in
                    state.mobileNumber = mobileNumber.withStarFormat()
                }
            case .failure:
                self.updateState { state in
                    state.mobileNumber = ""
                }
            }
        }
        self.updateState { state in
            state.state = .normal
        }
        self.setupTimer()
    }
    
    func submitCode(code : String) {
        self.expireTimer()
        self.updateState { state in
            state.state = .disabled
        }
        verificationService.verifyMobileNumberTAN(token: code) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let response):
                if response.verified {
                    self.updateState { state in
                        state.state = .success
                    }
                } else {
                    self.fail()
                }
            case .failure(_):
                self.fail()
            }
        }
    }
    
    func beginBankIdentification() {
        callback(.success(.phoneVerified))
    }
    
    func quit() {
        callback(.success(.abort))
    }
    
    private func updateState(_ update: @escaping (inout PhoneVerificationState) -> Void) {
        DispatchQueue.main.async {
            update(&self.state)
            self.updateView?.updateView(self.state)
        }
    }
    
    // Timer service
    
    private func setupTimer() {
        requestTimer = Timer.scheduledTimer(withTimeInterval: Constants.updateTimerInterval, repeats: true, block: { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.updateTimer()
        })
        
        counts = 20
        self.updateState { state in
            state.state = .remainingTime
            state.seconds = self.counts
        }
    }
    
    private func expireTimer() {
        requestTimer?.invalidate()
        self.updateState { state in
            state.state = .requestCode
        }
    }
    
    private func fail() {
        self.expireTimer()
        self.updateState { state in
            state.state = .error
        }
    }
    
    private func updateTimer() {
        counts -= 1
        if counts >= 1 {
            self.updateState { state in
                state.state = .remainingTime
                state.seconds = self.counts
            }
        } else {
            expireTimer()
        }
    }
    
}
