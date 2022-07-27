//
//  QESCoordinatorImpl.swift
//  IdentHubSDKQES
//
import Foundation
import IdentHubSDKCore

final internal class QESCoordinatorImpl: QESCoordinator {
    private let presenter: Presenter
    private let verificationService: VerificationService
    private let documentExporter: DocumentExporter
    private let actionPerformer: ActionPerformer
    private let actionFactory: ActionFactory
    private let colors: Colors

    private var storage: Storage

    private var input: QESInput!
    private var callback: ((Result<QESOutput, APIError>) -> Void)!

    init(
        presenter: Presenter,
        actionFactory: ActionFactory,
        verificationService: VerificationService,
        storage: Storage,
        documentExporter: DocumentExporter,
        colors: Colors
    ) {

        self.presenter = presenter
        self.actionFactory = actionFactory
        self.verificationService = verificationService
        self.storage = storage
        self.documentExporter = documentExporter
        self.colors = colors
        self.actionPerformer = ActionPerformer()
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

        let action = actionFactory.makeConfirmApplicationAction()
        let input = ConfirmApplicationActionInput(identificationUID: input.identificationUID)
        return actionPerformer.performAction(action, input: input) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return true
            }
            switch result {
            case .confirmedApplication:
                self.signDocuments()?.push(on: self.presenter)
                return true
            default:
                self.performDocumentAction(result)
                return false
            }
        }
    }
    
    private func signDocuments() -> Showable? {
        let action = actionFactory.makeSignDocumentsAction()
        let input = SignDocumentsActionInput(
            identificationUID: input.identificationUID,
            mobileNumber: input.mobileNumber
        )

        storage[.step] = .signDocuments

        return actionPerformer.performAction(action, input: input) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return true
            }
            switch result {
            case .success(let output):
                switch output {
                case .identificationConfirmed(let token):
                    self.callback(.success(.identificationConfirmed(identificationToken: token)))
                    return true
                case .quit:
                    self.quit()
                    return false
                }
            case .failure(let error):
                self.callback(.failure(error))
                return true
            }
        }
    }
    
    private func performDocumentAction(_ output: ConfirmApplicationActionOutput) {
        switch output {
        case .previewDocument(let url):
            self.previewDocument(url: url)
        case .downloadDocument(let url):
            self.downloadDocument(url: url)
        case .quit:
            self.quit()
        default:
            break
        }
    }

    private func previewDocument(url: URL) {
        let action = actionFactory.makePreviewDocumentAction()
        _ = actionPerformer.performAction(action, input: url) { result in
            return true
        }
    }
    
    private func downloadDocument(url: URL) {
        let action = actionFactory.makeDownloadDocumentAction()
        _ = actionPerformer.performAction(action, input: url, callback: { result in
            return true
        })
    }
    
    private func quit() {
        let action = actionFactory.makeQuitAction()
        actionPerformer.performAction(action) { [weak self] shouldClose in
            guard let self = self else {
                Assert.notNil(self)
                return true
            }

            if shouldClose {
                self.callback(.success(.abort))
            }
            return true
        }?.present(on: presenter, animated: false)
    }
}
