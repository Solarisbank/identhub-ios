//
//  PaymentVerificationViewModel.swift
//  IdentHubSDK
//

import Foundation

final internal class PaymentVerificationViewModel: NSObject {

    /// Delegate which informs about the current state of the performed action.
    weak var delegate: PaymentVerificationViewModelDelegate?

    private let flowCoordinator: BankIDCoordinator

    private let verificationService: VerificationService

    private let sessionStorage: StorageSessionInfoProvider

    init(flowCoordinator: BankIDCoordinator, delegate: PaymentVerificationViewModelDelegate, verificationService: VerificationService, sessionStorage: StorageSessionInfoProvider) {
        self.flowCoordinator = flowCoordinator
        self.delegate = delegate
        self.verificationService = verificationService
        self.sessionStorage = sessionStorage
        super.init()
        assemblyURLRequest()
    }

    private func assemblyURLRequest() {
        delegate?.verificationStarted()
        guard let path = sessionStorage.identificationPath,
              let url = URL(string: path) else {
            delegate?.verificationFailed()
            return
        }
        let urlRequest = URLRequest(url: url)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.delegate?.verificationRecivedURLRequest(urlRequest)
        }
    }

    // MARK: Methods

    /// Check the status of the identification.
    func checkIdentificationStatus() {
        verificationService.getIdentification { [weak self] result in
            switch result {
            case .success(let response):
                if response.status == Status.authorizationRequired.rawValue {
                    DispatchQueue.main.async {
                        self?.delegate?.verificationIsBeingProcessed()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                        self?.delegate?.verificationSucceeded()
                    }
                }
            default:
                break
            }
        }
    }

    /// Begin sign documents.
    func beginSignDocuments() {
        flowCoordinator.perform(action: .signDocuments(step: .confirmApplication))
    }
}

protocol PaymentVerificationViewModelDelegate: VerifiableViewModelDelegate {

    /// Called when the url request for verification is received.
    func verificationRecivedURLRequest(_ urlRequest: URLRequest)

    /// Called when the verification is being processed.
    func verificationIsBeingProcessed()
}
