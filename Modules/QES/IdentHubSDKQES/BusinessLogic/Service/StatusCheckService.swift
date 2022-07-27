//
//  StatusCheckService.swift
//  IdentHubSDKQES
//
import Foundation
import IdentHubSDKCore

internal protocol StatusCheckService {
    func setupNewCodeTimer(callback: @escaping (Int) -> Void)
    func setupStatusVerificationTimer(
        identificationUID: String,
        callback: @escaping (Result<String, APIError>) -> Void
    )
    func invalidateNewCodeTimer()
}

final internal class StatusCheckServiceImpl: StatusCheckService {
    typealias UpdateBlock = ((inout SignDocumentsState) -> Void) -> Void
    
    private let verificationService: VerificationService
    private let timerFactory: TimerFactory
    private let newCodeTimeout: Int
    private var requestTimer: Timer?
    private var statusVerificationTimer: Timer?

    init(
        verificationService: VerificationService,
        newCodeTimeout: Int = Constants.defaultSendNewCodeTimeout,
        timerFactory: TimerFactory
    ) {
        self.verificationService = verificationService
        self.newCodeTimeout = newCodeTimeout
        self.timerFactory = timerFactory
    }

    deinit {
        requestTimer?.invalidate()
        statusVerificationTimer?.invalidate()
    }

    func setupNewCodeTimer(callback: @escaping (Int) -> Void) {
        var secondsCounter = self.newCodeTimeout
        callback(secondsCounter)

        requestTimer = timerFactory.scheduledTimer(
            withTimeInterval: Constants.sendNewCodeInterval,
            repeats: true,
            block: { [weak self] timer in
                guard let self = self else {
                    return
                }

                secondsCounter -= 1
                if secondsCounter < 1 {
                    self.invalidateNewCodeTimer()
                }
                callback(secondsCounter)
            }
        )
    }
    
    func setupStatusVerificationTimer(
        identificationUID: String,
        callback: @escaping (Result<String, APIError>) -> Void
    ) {
        statusVerificationTimer = timerFactory.scheduledTimer(
            withTimeInterval: Constants.identificationStatusPullingInterval,
            repeats: true,
            block: { [weak self] timer in
                guard let self = self else {
                    return
                }
                self.verificationService.getIdentification(for: identificationUID) { [weak self] result in
                    guard let self = self else { return }

                    switch result {
                    case .success(let response):
                        DispatchQueue.main.async {
                            switch response.status {
                            case .success, .confirmed:
                                self.expireVerificationStatusTimer()
                                callback(.success(response.id))
                            default:
                                self.expireVerificationStatusTimer()
                                callback(.failure(.authorizationFailed))
                            }
                        }
                    case .failure(let error):
                        self.expireVerificationStatusTimer()
                        callback(.failure(error.apiError))
                    }
                }
            }
        )
    }
    
    func invalidateNewCodeTimer() {
        requestTimer?.invalidate()
    }
    
    /// Method invalidates verification status timer
    private func expireVerificationStatusTimer() {
        statusVerificationTimer?.invalidate()
    }
    
    /// Method invalidates verification status timer
    private func invalidateVerificationStatusTimer() {
        statusVerificationTimer?.invalidate()
    }
}

private extension StatusCheckServiceImpl {
    enum Constants {
        static var defaultSendNewCodeTimeout: Int { 20 }
        static var sendNewCodeInterval: TimeInterval { 1.0 }
        static var identificationStatusPullingInterval: TimeInterval { 3.0 }
    }
}
