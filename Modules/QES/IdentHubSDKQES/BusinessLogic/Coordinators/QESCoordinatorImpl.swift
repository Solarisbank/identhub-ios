//
//  QESCoordinatorImpl.swift
//  IdentHubSDKQES
//
import UIKit
import IdentHubSDKCore

final internal class QESCoordinatorImpl: QESCoordinator {
    private let presenter: Presenter
    private let verificationService: VerificationService
    private let alertsService: AlertsService
    private let showableFactory: ShowableFactory
    private let colors: Colors

    private var storage: Storage

    private var input: QESInput!
    private var callback: ((Result<QESOutput, APIError>) -> Void)!

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

    func start(input: QESInput, callback: @escaping (Result<QESOutput, APIError>) -> Void) -> Showable? {
        self.input = input
        self.callback = callback
    
        switch input.step {
        case .confirmAndSignDocuments: return confirmApplication()
        case .signDocuments: return signDocuments()
        }
    }
    
    private func confirmApplication() -> Showable? {
        guard storage[.step] != .signDocuments else {
            return signDocuments()
        }
        let input = ConfirmApplicationInput(identificationUID: input.identificationUID)
    
        return showableFactory.makeConfirmApplicationShowable(input: input) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }
            switch result {
            case .confirmedApplication:
                self.signDocuments()?.push(on: self.presenter)
            case .quit:
                self.quit()
            }
        }
    }
    
    private func signDocuments() -> Showable? {
        let input = SignDocumentsInput(
            identificationUID: input.identificationUID,
            mobileNumber: input.mobileNumber
        )

        storage[.step] = .signDocuments
        return showableFactory.makeSignDocumentsShowable(input: input) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }
            switch result {
            case .success(let output):
                switch output {
                case .identificationConfirmed(let token):
                    self.callback(.success(.identificationConfirmed(identificationToken: token)))
                case .quit:
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
