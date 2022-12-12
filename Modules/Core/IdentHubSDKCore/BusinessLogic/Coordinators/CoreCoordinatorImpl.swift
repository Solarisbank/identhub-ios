//
//  CoreCoordinatorImpl.swift
//  IdentHubSDKCore
//

import Foundation

final internal class CoreCoordinatorImpl: CoreCoordinator {
    private let presenter: Presenter
    private let verificationService: VerificationService
    private let alertsService: AlertsService
    private let showableFactory: ShowableFactory
    private let colors: Colors
    
    private var storage: Storage

    private var input: CoreInput!
    private var callback: ((Result<CoreOutput, APIError>) -> Void)!

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

    func start(input: CoreInput, callback: @escaping (Result<CoreOutput, APIError>) -> Void) -> Showable? {
        self.input = input
        self.callback = callback
    
        switch input.step {
        case .phoneVerification: return phoneVerification()
        }
    }
    
    private func phoneVerification() -> Showable? {
        let input = PhoneVerificationInput(identificationStep: self.input.identificationStep)
        
        return showableFactory.makePhoneVerificationShowable(input: input) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }
            
            switch result {
            case .success(let output):
                switch output {
                case .phoneVerified:
                    self.callback(.success(.phoneVerificationConfirm))
                case .abort:
                    self.quit()
                }
            case .failure(let error):
                self.callback(.failure(error))
            }
        }
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
