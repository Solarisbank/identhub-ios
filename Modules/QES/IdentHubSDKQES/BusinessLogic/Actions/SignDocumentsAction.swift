//
//  SignDocumentsAction.swift
//  IdentHubSDKQES
//
import Foundation
import IdentHubSDKCore

// MARK: - Input, Output and Dependencies

internal enum SignDocumentsActionOutput: Equatable {
    case identificationConfirmed(token: String)
    case quit
}

internal struct SignDocumentsActionInput {
    let identificationUID: String
    let mobileNumber: String?
}

// MARK: - Action -

final internal class SignDocumentsAction<ViewController: UpdateableShowable>: Action
    where ViewController.EventHandler == SignDocumentsEventHandler, ViewController.ViewState == SignDocumentsState {
    
    private let verificationService: VerificationService
    private let statusCheckService: StatusCheckService
    private var viewController: ViewController
    private var logic: SignDocumentsLogic?

    init(
        viewController: ViewController,
        verificationService: VerificationService,
        statusCheckService: StatusCheckService
    ) {
        self.viewController = viewController
        self.verificationService = verificationService
        self.statusCheckService = statusCheckService
    }

    func perform(
        input: SignDocumentsActionInput,
        callback: @escaping (Result<SignDocumentsActionOutput, APIError>) -> Void
    ) -> Showable? {

        logic = SignDocumentsLogic(
            verificationService: verificationService,
            statusCheckService: statusCheckService,
            input: input,
            callback: callback,
            updateStateCallback: viewController.updateView(_:)
        )
        viewController.eventHandler = logic

        logic?.loadMobileNumber()

        return viewController
    }
}

// MARK: - Logic -

private class SignDocumentsLogic: SignDocumentsEventHandler {
    typealias Callback = (Result<SignDocumentsActionOutput, APIError>) -> Void
    typealias UpdateStateCallback = (SignDocumentsState) -> Void

    private let verificationService: VerificationService
    private let statusCheckService: StatusCheckService

    private var state: SignDocumentsState
    private var input: SignDocumentsActionInput
    private var callback: Callback
    private var updateStateCallback: UpdateStateCallback

    init(
        verificationService: VerificationService,
        statusCheckService: StatusCheckService,
        input: SignDocumentsActionInput,
        callback: @escaping Callback,
        updateStateCallback: @escaping UpdateStateCallback
    ) {

        self.verificationService = verificationService
        self.statusCheckService = statusCheckService

        self.input = input
        self.callback = callback
        self.updateStateCallback = updateStateCallback

        self.state = SignDocumentsState(mobileNumber: input.mobileNumber)
        
        updateStateCallback(state)
    }

    func loadMobileNumber() {
        if input.mobileNumber == nil {
            verificationService.getMobileNumber { result in
                result.onSuccess { mobileNumber in
                    self.updateState { state in
                        state.mobileNumber = mobileNumber.number
                    }
                }
            }
        }
    }

    func submitCodeAndSign(_ code: String) {
        statusCheckService.invalidateNewCodeTimer()

        updateState { state in
            state.state = .verifyingCode
            state.newCodeRemainingTime = 0
        }
        
        verificationService.verifyDocumentsTAN(identificationUID: input.identificationUID, token: code) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                if response.status == Status.confirmed {
                    self.updateState { state in
                        state.state = .processingIdentfication
                    }
                    
                    DispatchQueue.main.async {
                        self.statusCheckService.setupStatusVerificationTimer(identificationUID: self.input.identificationUID) { [weak self] result in
                            switch result {
                            case .success(let identificationToken):
                                self?.updateState { state in
                                    state.state = .identificationSuccessful
                                }

                                self?.callback(.success(.identificationConfirmed(token: identificationToken)))
                            case .failure(let error):
                                self?.callback(.failure(error))
                            }
                        }
                    }
                } else {
                    fallthrough
                }
            case .failure:
                self.statusCheckService.invalidateNewCodeTimer()
                self.updateState { state in
                    state.state = .codeInvalid
                    state.newCodeRemainingTime = 0
                }
            }
        }
    }

    func requestNewCode() {
        updateState { state in
            state.state = .requestingCode
            state.newCodeRemainingTime = 0
        }

        statusCheckService.setupNewCodeTimer { [weak self] newCodeRemainingTime in
            self?.updateState({ state in
                state.newCodeRemainingTime = newCodeRemainingTime
            })
        }
        
        verificationService.authorizeDocuments(identificationUID: input.identificationUID) { [weak self] response in
            switch response {
            case .success(let identification):
                self?.updateState({ state in
                    state.state = .codeAvailable
                    state.transactionId = identification.referenceToken
                })
            case .failure(_):
                self?.statusCheckService.invalidateNewCodeTimer()
                self?.updateState({ state in
                    state.state = .codeUnavailable
                })
            }
        }
    }
    
    func quit() {
        callback(.success(.quit))
    }

    private func updateState(_ update: @escaping (inout SignDocumentsState) -> Void) {
        DispatchQueue.main.async {
            update(&self.state)
            self.updateStateCallback(self.state)
        }
    }
}
