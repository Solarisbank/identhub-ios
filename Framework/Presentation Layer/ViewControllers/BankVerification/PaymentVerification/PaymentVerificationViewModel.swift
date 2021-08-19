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

    private var completionHandler: CompletionHandler

    private var nextStep: IdentificationStep = .unspecified

    private var timer: Timer?

    init(flowCoordinator: BankIDCoordinator, verificationService: VerificationService, sessionStorage: StorageSessionInfoProvider, completion: @escaping CompletionHandler) {
        self.flowCoordinator = flowCoordinator
        self.verificationService = verificationService
        self.sessionStorage = sessionStorage
        self.completionHandler = completion
        super.init()
    }

    // MARK: Methods

    /// Assembly payment verification process
    func assemblyURLRequest() {
        delegate?.verificationStarted()
        guard let path = sessionStorage.identificationPath,
              let url = URL(string: path) else {
            delegate?.verificationFailed()
            completionHandler(.failure(APIError.requestError))
            return
        }
        let urlRequest = URLRequest(url: url)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.verificationRecivedURLRequest(urlRequest)
        }

        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(checkIdentificationStatus), userInfo: nil, repeats: true)
    }

    /// Begin sign documents.
    func beginSignDocuments() {
        if nextStep != .unspecified {
            flowCoordinator.perform(action: .nextStep(step: nextStep))
        } else {
            flowCoordinator.perform(action: .signDocuments(step: .confirmApplication))
        }
    }
}

private extension PaymentVerificationViewModel {

    /// Check the payment status of the identification.
    @objc private func checkIdentificationStatus() {
        verificationService.getIdentification { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .success(let response):

                switch response.status {
                case .authorizationRequired,
                     .identificationRequired:
                    if let step = response.nextStep, let nextStep = IdentificationStep(rawValue: step) {
                        self.nextStep = nextStep
                    }

                    DispatchQueue.main.async {
                        self.timer?.invalidate()
                        self.delegate?.verificationIsBeingProcessed()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.delegate?.verificationSucceeded()
                    }
                case .failed:
                    DispatchQueue.main.async {
                        self.completionHandler(.failure(.paymentFailed))
                        self.flowCoordinator.perform(action: .close)
                    }
                default:
                    print("Status not processed in SDK: \(response.status.rawValue)")
                }
            case .failure(let error):
                self.completionHandler(.failure(error))
            }
        }
    }
}

protocol PaymentVerificationViewModelDelegate: VerifiableViewModelDelegate {

    /// Called when the url request for verification is received.
    func verificationRecivedURLRequest(_ urlRequest: URLRequest)

    /// Called when the verification is being processed.
    func verificationIsBeingProcessed()
}
