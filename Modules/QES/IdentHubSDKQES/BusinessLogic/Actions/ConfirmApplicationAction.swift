//
//  ConfirmApplicationAction.swift
//  IdentHubSDKQES
//
import Foundation
import IdentHubSDKCore

internal enum ConfirmApplicationActionOutput: Equatable {
    case confirmedApplication
    case previewDocument(url: URL)
    case downloadDocument(url: URL)
    case quit
}

internal struct ConfirmApplicationActionInput {
    var identificationUID: String
}

final internal class ConfirmApplicationAction<ViewController: UpdateableShowable>: Action
    where ViewController.ViewState == ConfirmApplicationState, ViewController.EventHandler == ConfirmApplicationEventHandler {

    private let verificationService: VerificationService

    private var viewController: ViewController
    private var logic: ConfirmApplicationLogic?

    init(presenter: ViewController, verificationService: VerificationService) {
        self.verificationService = verificationService
        self.viewController = presenter
    }

    func perform(
        input: ConfirmApplicationActionInput,
        callback: @escaping (ConfirmApplicationActionOutput) -> Void
    ) -> Showable? {

        logic = ConfirmApplicationLogic(
            verificationService: verificationService,
            input: input,
            callback: callback,
            updateStateCallback: viewController.updateView(_:)
        )
        viewController.eventHandler = logic
        return viewController
    }
}

final private class ConfirmApplicationLogic: ConfirmApplicationEventHandler {
    typealias Callback = (ConfirmApplicationActionOutput) -> Void
    typealias UpdateStateCallback = (ConfirmApplicationState) -> Void

    private let verificationService: VerificationService

    private var state: ConfirmApplicationState
    private var input: ConfirmApplicationActionInput
    private var callback: Callback
    private var updateStateCallback: UpdateStateCallback

    init(
        verificationService: VerificationService,
        input: ConfirmApplicationActionInput,
        callback: @escaping Callback,
        updateStateCallback: @escaping UpdateStateCallback
    ) {

        self.verificationService = verificationService

        self.input = input
        self.callback = callback
        self.updateStateCallback = updateStateCallback

        self.state = ConfirmApplicationState()
        
        updateStateCallback(state)
    }

    func loadDocuments() {
        verificationService.getIdentification(for: input.identificationUID) { [weak self] result in
            switch result {
            case .success(let response):
                guard let documents = response.documents else { break }
                self?.updateState { state in
                    state.documents = documents.map { LoadableDocument(
                            isLoading: false,
                            document: $0
                        )
                    }
                }
            default:
                break
            }
        }
    }

    func signDocuments() {
        callback(.confirmedApplication)
    }

    func previewDocument(withId id: String) {
        downloadDocument(withId: id) { [weak self] url in
            self?.callback(.previewDocument(url: url))
        }
    }
    
    func downloadDocument(withId id: String) {
        downloadDocument(withId: id) { [weak self] url in
            self?.callback(.downloadDocument(url: url))
        }
    }

    func quit() {
        callback(.quit)
    }
    
    private func downloadDocument(withId id: String, callback: @escaping (URL) -> Void) {
        updateState { state in
            state.documents.updateLoading(for: id, isLoading: true)
        }

        verificationService.downloadAndSaveDocument(withId: id) { [weak self] result in
            result
                .onSuccess { url in
                    self?.updateState { state in
                        state.documents.updateLoading(for: id, isLoading: false)
                        callback(url)
                    }
                }
                .onFailure { error in
                    print("Error! Document download error \(error)")
                }
        }
    }

    private func updateState(_ update: @escaping (inout ConfirmApplicationState) -> Void) {
        DispatchQueue.main.async {
            update(&self.state)
            self.updateStateCallback(self.state)
        }
    }
}

private extension Array where Element == LoadableDocument {
    mutating func updateLoading(for id: String, isLoading: Bool) {
        if let index = firstIndex(where: { $0.document.id == id }) {
            self[index].isLoading = isLoading
        }
    }
}
