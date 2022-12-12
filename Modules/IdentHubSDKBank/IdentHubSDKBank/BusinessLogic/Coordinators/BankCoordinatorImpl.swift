//
//  BankCoordinatorImpl.swift
//  Bank
//

import Foundation
import IdentHubSDKCore

final internal class BankCoordinatorImpl: BankCoordinator {

    private let presenter: Presenter
    private let verificationService: VerificationService
    private let alertsService: AlertsService
    private let showableFactory: ShowableFactory
    private let colors: Colors
    
    private var storage: Storage
    
    private var input: BankInput!
    private var callback: ((Result<BankOutput, APIError>) -> Void)!

    init(
        presenter: Presenter,
        showableFactory: ShowableFactory,
        verificationService: VerificationService,
        alertsService: AlertsService,
        storage: Storage,
        colors: Colors
    ) {
        self.presenter = presenter
        self.showableFactory = showableFactory
        self.verificationService = verificationService
        self.storage = storage
        self.colors = colors
        self.alertsService = alertsService
    }

    func start(input: BankInput, callback: @escaping (Result<BankOutput, APIError>) -> Void) -> Showable? {
        self.input = input
        self.callback = callback
        
        setStorageValue()
        
        bankLog.info("\(input.step)")
        switch input.step {
        case .bankVerification(let step):
            switch step {
            case .iban:
                return presentIBANVerification()
            case .payment:
                return presentPaymentVerification()
            }
        case .nextStep(let step): return performIdentStep(step: step)
        }
    }
    
    func setStorageValue() {
        storage[.retriesCount] = input.retriesCount
        storage[.fallbackIdentStep] = input.fallbackIdentStep
    }
    
    private func presentIBANVerification() -> Showable? {
        guard storage[.step] != .bankVerification(step: .payment) else {
            return presentPaymentVerification()
        }
        let input = IBANVerificationInput(identificationStep: self.input.identificationStep)
        
        return showableFactory.makeIBANVerificationShowable(input: input) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }
            
            switch result {
            case .ibanVerified:
                self.presentPaymentVerification()?.push(on: self.presenter)
            case .nextStep(step: let step):
                _ = self.performIdentStep(step: step)
            case .abort:
                self.quit()
            case .failure(let error):
                self.callback(.failure(error))
            }
        }
    }
    
    private func presentPaymentVerification() -> Showable? {
        let input = PaymentVerificationInput(identificationStep: self.input.identificationStep)
        
        self.storage[.step] = .bankVerification(step: .payment)
        return showableFactory.makePaymentVerificationShowable(input: input) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }
            
            switch result {
            case .paymentVerified:
                let identUID = self.storage[.identificationUID] ?? ""
                self.callback(.success(.performQES(identID: identUID)))
            case .nextStep(step: let step):
                _ = self.performIdentStep(step: step)
            case .abort:
                self.quit()
            case .failure(let error):
                self.callback(.failure(error))
            }
        }
    }
    
    private func performIdentStep(step: IdentificationStep) -> Showable? {
        let identUID = self.storage[.identificationUID] ?? ""
        callback(.success(.nextStep(step: step, identUID)))
        return nil
    }
    
    private func quit() {
        alertsService.presentQuitAlert { [weak self] shouldClose in
            guard let self = self else {
                Assert.notNil(self)
                return
            }

            if shouldClose {
                self.callback(.success(.abort))
            }
        }
    }
    
}
