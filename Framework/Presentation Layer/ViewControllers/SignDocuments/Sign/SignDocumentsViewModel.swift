//
//  SignDocumentsViewModel.swift
//  IdentHubSDK
//

import Foundation

/// ViewModel which supports sign documents view controller.
final internal class SignDocumentsViewModel: NSObject {

    /// Delegate which informs about the current state of the performed action.
    weak var delegate: SignDocumentsViewModelDelegate?

    private let flowCoordinator: BankIDCoordinator

    private let verificationService: VerificationService

    private let sessionStorage: StorageSessionInfoProvider

    /// Mobile number used for current authorization.
    lazy var mobileNumber = {
        self.sessionStorage.mobileNumber ?? ""
    }()

    init(flowCoordinator: BankIDCoordinator, delegate: SignDocumentsViewModelDelegate, verificationService: VerificationService, sessionStorage: StorageSessionInfoProvider) {
        self.flowCoordinator = flowCoordinator
        self.delegate = delegate
        self.verificationService = verificationService
        self.sessionStorage = sessionStorage
        super.init()
        requestNewCode()
    }

    private func requestNewCode() {
        verificationService.authorizeDocuments { _ in }
    }

    private func fail() {
        DispatchQueue.main.async {
            self.delegate?.verificationFailed()
        }
    }

    // MARK: Methods

    /// Submit code.
    func submitCodeAndSign(_ code: String?) {
        guard let code = code else { return }
        delegate?.verificationStarted()
        verificationService.verifyDocumentsTAN(token: code) { [weak self] result in
            switch result {
            case .success(let response):
                if response.status == Status.confirmed.rawValue {
                    DispatchQueue.main.async {
                        self?.delegate?.verificationIsBeingProcessed()
                    }
                } else {
                    self?.fail()
                }
            case .failure(_):
                self?.fail()
            }
        }
    }

    /// Check the status of the identification.
    func checkIdentificationStatus() {
        verificationService.getIdentification { [weak self] result in
            switch result {
            case .success(let response):
                if response.status == Status.successful.rawValue {
                    DispatchQueue.main.async {
                        self?.delegate?.verificationSucceeded()
                    }
                } else {
                    self?.fail()
                }
            case .failure(_):
                self?.fail()
            }
        }
    }

    /// Display finish identification screen.
    func finishIdentification() {
        flowCoordinator.perform(action: .finishIdentification)
    }
}

protocol SignDocumentsViewModelDelegate: VerifiableViewModelDelegate {

    /// Called when the verification is being processed.
    func verificationIsBeingProcessed()
}
