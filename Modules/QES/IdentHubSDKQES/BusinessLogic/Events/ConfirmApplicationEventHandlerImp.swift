//
//  ConfirmApplicationAction.swift
//  IdentHubSDKQES
//
import Foundation
import IdentHubSDKCore
import UIKit

internal enum ConfirmApplicationOutput: Equatable {
    case confirmedApplication
    case quit
}

internal struct ConfirmApplicationInput {
    var identificationUID: String
}

// MARK: - Confirm application events logic -

typealias ConfirmApplicationCallback = (ConfirmApplicationOutput) -> Void

final internal class ConfirmApplicationEventHandlerImpl<ViewController: UpdateableShowable>: ConfirmApplicationEventHandler where ViewController.EventHandler == ConfirmApplicationEventHandler, ViewController.ViewState == ConfirmApplicationState {
    
    weak var updatableView: ViewController? {
        didSet {
            updatableView?.updateView(state)
        }
    }
    
    private let verificationService: VerificationService
    private var documentExporter: DocumentExporter
    private var state: ConfirmApplicationState
    private var input: ConfirmApplicationInput
    private var callback: ConfirmApplicationCallback

    init(
        verificationService: VerificationService,
        documentExporter: DocumentExporter,
        input: ConfirmApplicationInput,
        callback: @escaping ConfirmApplicationCallback
    ) {

        self.verificationService = verificationService
        self.documentExporter = documentExporter
        self.input = input
        self.callback = callback
        
        self.state = ConfirmApplicationState()
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
            guard let showable = self?.updatableView else { return }
            self?.documentExporter.presentPreviewer(from: showable, documentURL: url)
        }
    }
    
    func downloadDocument(withId id: String) {
        downloadDocument(withId: id) { [weak self] url in
            guard let showable = self?.updatableView else { return }
            self?.documentExporter.presentExporter(from: showable, in: .zero, documentURL: url)
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
            self.updatableView?.updateView(self.state)
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
