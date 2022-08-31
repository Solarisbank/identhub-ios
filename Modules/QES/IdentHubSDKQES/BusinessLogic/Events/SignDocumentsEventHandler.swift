//
//  SignDocumentsAction.swift
//  IdentHubSDKQES
//
import Foundation
import IdentHubSDKCore

// MARK: - Input, Output and Dependencies

internal enum SignDocumentsOutput: Equatable {
    case identificationConfirmed(token: String)
    case quit
}

internal struct SignDocumentsInput {
    let identificationUID: String
    let mobileNumber: String?
}

// MARK: - Events Logic -

typealias SignDocumentsCallback = (Result<SignDocumentsOutput, APIError>) -> Void

final internal class SignDocumentsEventHandlerImpl<ViewController: UpdateableShowable>: EventHandler where ViewController.EventHandler == AnyEventHandler<SignDocumentsEvent>, ViewController.ViewState == SignDocumentsState {
    
    weak var updatableView: ViewController? {
        didSet {
            updatableView?.updateView(state)
        }
    }
    
    private let verificationService: VerificationService
    private let statusCheckService: StatusCheckService

    private var state: SignDocumentsState
    private var input: SignDocumentsInput
    private var callback: SignDocumentsCallback

    init(
        verificationService: VerificationService,
        statusCheckService: StatusCheckService,
        input: SignDocumentsInput,
        callback: @escaping SignDocumentsCallback
    ) {

        self.verificationService = verificationService
        self.statusCheckService = statusCheckService

        self.input = input
        self.callback = callback

        self.state = SignDocumentsState(mobileNumber: input.mobileNumber)

        loadMobileNumber()
    }
    
    func handleEvent(_ event: SignDocumentsEvent) {
        switch event {
        case .requestNewCode:
            requestNewCode()
        case .submitCodeAndSign(let code):
            submitCodeAndSign(code)
        case .quit:
            quit()
        }
    }

    func loadMobileNumber() {
        if input.mobileNumber == nil {
            verificationService.getMobileNumber { [weak self] result in
                result.onSuccess { mobileNumber in
                    self?.updateState { state in
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
            self.updatableView?.updateView(self.state)
        }
    }
}
