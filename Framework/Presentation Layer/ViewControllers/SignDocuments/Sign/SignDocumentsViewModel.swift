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

    private var completionHander: CompletionHandler
    
    private var identMethod: IdentificationStep?

    /// Mobile number used for current authorization.
    lazy var mobileNumber = {
        self.sessionStorage.mobileNumber ?? ""
    }()

    init(flowCoordinator: BankIDCoordinator, delegate: SignDocumentsViewModelDelegate, verificationService: VerificationService, sessionStorage: StorageSessionInfoProvider, completion: @escaping CompletionHandler) {
        self.flowCoordinator = flowCoordinator
        self.delegate = delegate
        self.verificationService = verificationService
        self.sessionStorage = sessionStorage
        self.completionHander = completion
        self.identMethod = sessionStorage.identificationStep
        super.init()
        requestNewCode()
    }

    private func fail() {
        self.sessionStorage.isSuccessful = false
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
            guard let `self` = self else { return }

            switch result {
            case .success(let response):
                if response.status == Status.confirmed {
                    DispatchQueue.main.async {
                        self.delegate?.verificationIsBeingProcessed()
                    }
                } else {
                    self.fail()
                    self.completionHander(.failure(.authorizationFailed))
                }
            case .failure(let error):
                self.fail()
                self.completionHander(.failure(error.apiError))
            }
        }
    }

    func requestNewCode() {
        verificationService.authorizeDocuments { [weak self] _ in

            self?.delegate?.didSubmitNewCodeRequest()
        }
    }

    func quit() {
        flowCoordinator.perform(action: .quit)
    }

    /// Check the status of the identification.
    func checkIdentificationStatus() {
        verificationService.getIdentification { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    switch response.status {
                    case .success:
                        self.delegate?.verificationSucceeded()
                    case .confirmed:
                        self.delegate?.verificationSucceeded()
                        self.completionHander(.onConfirm(identification: response.id))
                        self.flowCoordinator.perform(action: .close)
                    default:
                        self.fail()
                        self.completionHander(.failure(.authorizationFailed))
                    }
                }
            case .failure(let error):
                self.fail()
                self.completionHander(.failure(error.apiError))
            }
        }
    }

    /// Display finish identification screen.
    func finishIdentification() {
        self.sessionStorage.isSuccessful = true
        flowCoordinator.perform(action: .finishIdentification)
    }
    
    /// Method defines if progress view should be visible
    /// - Returns: bool status of progress visibility
    func isVisibleProgress() -> Bool {
        return ( identMethod != .fourthlineSigning )
    }
}

protocol SignDocumentsViewModelDelegate: VerifiableViewModelDelegate {

    /// Called when the verification is being processed.
    func verificationIsBeingProcessed()

    /// Did publish request for new TAN
    func didSubmitNewCodeRequest()
}
