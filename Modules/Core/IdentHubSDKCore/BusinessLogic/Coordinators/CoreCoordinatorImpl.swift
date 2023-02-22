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
    var sessionInfoProvider: StorageSessionInfoProvider!
    
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
        self.sessionInfoProvider = StorageSessionInfoProvider(sessionToken: input.sessionToken ?? "")
        return perform(step: input.step)
    }
    
    func perform(step: CoreStep) -> Showable? {
        switch step {
        case .initateFlow: return initateFlow()
        case .termsConditions: return termsConditions()
        case .phoneVerification: return phoneVerification()
        }
    }
    
    private func phoneVerification() -> Showable? {
        storage[.step] = .phoneVerification
        return showableFactory.makePhoneVerificationShowable(session: self.sessionInfoProvider) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }
            
            switch result {
            case .success(let output):
                switch output {
                case .phoneVerified:
                    self.sessionInfoProvider.phoneVerified = true
                    self.sessionInfoProvider.performedPhoneVerification = true
                    self.callback(.success(.startIdentification(self.sessionInfoProvider)))
                case .abort:
                    self.quit()
                }
            case .failure(let error):
                self.callback(.failure(error))
            }
        }
    }
    
    private func initateFlow() -> Showable? {
        let input = RequestsInput(requestsType: .initateFlow, initStep: .defineMethod)
        
        storage[.step] = .initateFlow
        return showableFactory.makeRequestsShowable(input: input, session: self.sessionInfoProvider) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }
                                    
            switch result {
            case .finishInitialFetch(let response):
                self.callback(.success(.startIdentification(self.sessionInfoProvider, info: response)))
            case .fourthline(let step):
                self.callback(.success(.fourthline(step , self.storage[.fourthlineProvider])))
            case .failure(let error):
                self.callback(.failure(error))
            case .quit:
                self.quit()
            }
        }
    }
    
    private func termsConditions() -> Showable? {
        if storage[.step] == .phoneVerification {
            return phoneVerification()
        }
        
        storage[.step] = .termsConditions
        return showableFactory.makeTermsShowable(session: self.sessionInfoProvider) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }
            
            switch result {
            case .success(let output):
                switch output {
                case .termsVerified:
                    self.sessionInfoProvider.acceptedTC = true
                    self.sessionInfoProvider.performedTCAcceptance = true
                    self.performPrechecksThenProceed()
                case .abort:
                    self.quit()
                }
            case .failure(let error):
                self.callback(.failure(error))
            }
        }
        
    }
    
    private func performPrechecksThenProceed() {
        if let storage = self.sessionInfoProvider {
            if (!storage.phoneVerified){
                DispatchQueue.main.async {
                    self.phoneVerification()?.push(on: self.presenter)
                }
            } else {
                self.callback(.success(.startIdentification(self.sessionInfoProvider)))
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
