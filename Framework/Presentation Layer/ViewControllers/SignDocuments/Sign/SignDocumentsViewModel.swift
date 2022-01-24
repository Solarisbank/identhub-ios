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
    
    private var requestTimer: Timer?
    
    private var statusVerificationTimer: Timer?
    
    private var secoundsCounter = 20

    /// Mobile number used for current authorization.
    lazy var mobileNumber = {
        self.sessionStorage.mobileNumber ?? ""
    }()

    init(flowCoordinator: BankIDCoordinator, verificationService: VerificationService, sessionStorage: StorageSessionInfoProvider, completion: @escaping CompletionHandler) {
        self.flowCoordinator = flowCoordinator
        self.verificationService = verificationService
        self.sessionStorage = sessionStorage
        self.completionHander = completion
        self.identMethod = sessionStorage.identificationStep
        super.init()
    }

    // MARK: - Public methods -

    /// Submit code.
    func submitCodeAndSign(_ code: String?) {
        guard let code = code else { return }
        expireRequestNewCodeTimer()
        delegate?.verificationStarted()
        
        verificationService.verifyDocumentsTAN(token: code) { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .success(let response):
                if response.status == Status.confirmed {
                    DispatchQueue.main.async {
                        self.delegate?.verificationIsBeingProcessed()
                        self.setupStatusVerificationTimer()
                    }
                } else {
                    self.codeVerificationFailed()
                    self.completionHander(.failure)
                }
            case .failure(_):
                self.codeVerificationFailed()
                self.completionHander(.failure)
            }
        }
    }

    func requestNewCode() {
        verificationService.authorizeDocuments { [weak self] response in

            switch response {
            case .success(let identification):
                if let transactionToken = identification.referenceToken {
                    DispatchQueue.main.async {
                        self?.delegate?.didSubmitNewCodeRequest(transactionToken)
                    }
                }
            case .failure(let error):
                // TODO: - Discuss and implement solution with showing error message to the user -
                print(error.localizedDescription)
            }
        }
        
        setupRequestNewCodeTimer()
    }

    func quit() {
        flowCoordinator.perform(action: .quit)
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
    
    /// Method invalidates verification status timer
    func expireVerificationStatusTimer() {
        statusVerificationTimer?.invalidate()
    }
}

// MARK: - Internal methods -

private extension SignDocumentsViewModel {
    
    private func setupRequestNewCodeTimer() {
        requestTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        secoundsCounter = 20
        delegate?.didUpdateTimerLabel(String(describing: secoundsCounter))
    }
    
    private func setupStatusVerificationTimer() {
        statusVerificationTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(checkIdentificationStatus), userInfo: nil, repeats: true)
    }
    
    private func expireRequestNewCodeTimer() {
        requestTimer?.invalidate()
        delegate?.didEndTimerDelay()
    }
    
    private func codeVerificationFailed() {
        self.sessionStorage.isSuccessful = false
        DispatchQueue.main.async {
            self.delegate?.verificationFailed()
            self.expireRequestNewCodeTimer()
        }
    }
    
    @objc private func updateTimer() {
        secoundsCounter -= 1
        if secoundsCounter >= 1 {
            let secondString = (secoundsCounter >= 10) ? String(describing: secoundsCounter) : "0\(String(describing: secoundsCounter))"
            delegate?.didUpdateTimerLabel(secondString)
        } else {
            expireRequestNewCodeTimer()
        }
    }
    
    /// Check the status of the identification.
    @objc private func checkIdentificationStatus() {
        verificationService.getIdentification { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    switch response.status {
                    case .success:
                        self.delegate?.verificationSucceeded()
                    case .confirmed:
                        self.completionHander(.onConfirm(identification: response.id))
                        self.delegate?.verificationSucceeded()
                    default:
                        self.expireVerificationStatusTimer()
                        self.completionHander(.failure)
                    }
                    SessionStorage.clearData()
                }
            case .failure(_):
                self.expireVerificationStatusTimer()
                self.completionHander(.failure)
                self.flowCoordinator.perform(action: .close)
            }
        }
    }
}

protocol SignDocumentsViewModelDelegate: VerifiableViewModelDelegate {

    /// Called when the verification is being processed.
    func verificationIsBeingProcessed()

    /// Did publish request for new TAN
    /// - token: string value of the transaction ID
    func didSubmitNewCodeRequest(_ token: String)
    
    /// Method notified when timer expired.
    /// Display send new code request
    func didEndTimerDelay()
    
    /// Method updated count down timer label
    /// count - number of seconds
    func didUpdateTimerLabel(_ count: String)
}
