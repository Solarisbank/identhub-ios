//
//  PaymentVerificationViewModel.swift
//  IdentHubSDK
//

import Foundation

final internal class PaymentVerificationViewModel: NSObject, ViewModel {

    /// Delegate which informs about the current state of the performed action.
    weak var delegate: PaymentVerificationViewModelDelegate?

    private(set) weak var flowCoordinator: BankIDCoordinator?

    let verificationService: VerificationService

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
                  completionHandler(.failure(.requestError))
                  return
              }
        let urlRequest = URLRequest(url: url)
        DispatchQueue.main.asyncAfter(deadline: 1.seconds.fromNow) { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.verificationRecivedURLRequest(urlRequest)
        }

        timer = Timer.scheduledTimer(withTimeInterval: Constants.identificationStatusCheckInterval, repeats: true, block: { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                
                return
            }
            
            self.checkIdentificationStatus()
        })
    }

    /// Begin sign documents.
    func executeStep() {
        if nextStep != .unspecified {
            flowCoordinator?.perform(action: .nextStep(step: nextStep))
        } else {
            flowCoordinator?.perform(action: .signDocuments(step: .confirmApplication))
        }
    }
}

private extension PaymentVerificationViewModel {

    /// Check the payment status of the identification.
    private func checkIdentificationStatus() {
        verificationService.getIdentification { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .success(let response):
                self.defineNextStep(response)

                switch response.status {
                case .authorizationRequired,
                     .identificationRequired:
                    DispatchQueue.main.async {
                        self.timer?.invalidate()
                        self.delegate?.verificationIsBeingProcessed()
                    }
                    DispatchQueue.main.asyncAfter(deadline: 1.seconds.fromNow) {
                        self.delegate?.verificationSucceeded()
                    }
                case .failed:
                    if self.nextStep != .unspecified {
                        DispatchQueue.main.async {
                            self.timer?.invalidate()
                            self.executeStep()
                        }
                    } else {
                        self.interruptProcess()
                    }
                default:
                    print("Status not processed in SDK: \(response.status.rawValue)")
                }
            case .failure(let error):
                self.completionHandler(.failure(error.apiError))
            }
        }
    }

    private func defineNextStep(_ response: Identification) {
        if let step = response.nextStep, let nextStep = IdentificationStep(rawValue: step) {
            self.nextStep = nextStep
        } else if let step = response.fallbackStep, let fallbackStep = IdentificationStep(rawValue: step) {
            self.nextStep = fallbackStep
        } else {
            self.nextStep = .unspecified
        }
    }

    private func interruptProcess() {
        DispatchQueue.main.async {
            self.completionHandler(.failure(.paymentFailed))
            self.flowCoordinator?.perform(action: .close)
        }
    }
}

protocol PaymentVerificationViewModelDelegate: VerifiableViewModelDelegate {

    /// Called when the url request for verification is received.
    func verificationRecivedURLRequest(_ urlRequest: URLRequest)

    /// Called when the verification is being processed.
    func verificationIsBeingProcessed()
}

private extension PaymentVerificationViewModel {
    enum Constants {
        static let identificationStatusCheckInterval: TimeInterval = 3.0
    }
}
