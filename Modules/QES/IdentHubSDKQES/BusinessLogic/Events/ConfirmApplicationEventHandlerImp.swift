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
    var identificationStep: IdentificationStep?
}

// MARK: - Confirm application events logic -

typealias ConfirmApplicationCallback = (ConfirmApplicationOutput) -> Void

final internal class ConfirmApplicationEventHandlerImpl<ViewController: UpdateableShowable>: EventHandler where ViewController.EventHandler == AnyEventHandler<ConfirmApplicationEvent>, ViewController.ViewState == ConfirmApplicationState {
    
    weak var updatableView: ViewController? {
        didSet {
            updatableView?.updateView(state)
        }
    }
    
    private let verificationService: VerificationService
    private let alertsService: AlertsService
    private let documentExporter: DocumentExporter
    private var state: ConfirmApplicationState
    private var input: ConfirmApplicationInput
    private var callback: ConfirmApplicationCallback

    init(
        verificationService: VerificationService,
        alertsService: AlertsService,
        documentExporter: DocumentExporter,
        input: ConfirmApplicationInput,
        callback: @escaping ConfirmApplicationCallback
    ) {

        self.verificationService = verificationService
        self.alertsService = alertsService
        self.documentExporter = documentExporter
        self.input = input
        self.callback = callback
        self.state = ConfirmApplicationState(hasQuitButton: true,
                                             documents: [],
                                             hasTermsAndConditionsLink: input.identificationStep == .bankQES)
    }

    func handleEvent(_ event: ConfirmApplicationEvent) {
        switch event {
        case .loadDocuments:
            loadDocuments()
        case .signDocuments:
            signDocuments()
        case .previewDocument(let id):
            previewDocument(withId: id)
        case .downloadDocument(let id):
            downloadDocument(withId: id)
        case .quit:
            quit()
        }
    }

    func loadDocuments() {
        qesLog.info("Fetching documents")
        
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
        qesLog.info("Fetching document for preview")
        
        fetchDocument(
            withId: id,
            success: { [weak self] url in
                guard let showable = self?.updatableView else { return }
                self?.documentExporter.presentPreviewer(from: showable, documentURL: url)

            },
            retry: { [weak self] in
                self?.previewDocument(withId: id)
            }
        )
    }
    
    func downloadDocument(withId id: String) {
        qesLog.info("Fetching document for \"open in...\"")
        
        fetchDocument(
            withId: id,
            success: { [weak self] url in
                guard let showable = self?.updatableView else { return }
                self?.documentExporter.presentExporter(from: showable, in: .zero, documentURL: url)

            },
            retry: { [weak self] in
                self?.downloadDocument(withId: id)
            }
        )
    }

    func quit() {
        callback(.quit)
    }
    
    private func fetchDocument(withId id: String, success: @escaping (URL) -> Void, retry: @escaping () -> Void) {
        guard state.documents.isNotLoadingAnyDocument else {
            qesLog.warn("Action skipped as other documents are already loading.")
            
            return
        }
        
        updateState { state in
            state.documents.updateLoading(for: id, isLoading: true)
        }

        verificationService.downloadAndSaveDocument(withId: id) { [weak self] result in
            self?.updateState { state in
                state.documents.updateLoading(for: id, isLoading: false)

                result
                    .onSuccess { url in
                        qesLog.info("Document fetch success: \(url.lastPathComponent)")
                        
                        success(url)
                    }
                    .onFailure { [state] error in
                        let documentName = state.documents.name(for: id) ?? id

                        qesLog.warn("Document fetch failure: \(documentName) with error: \(error.localizedDescription)")

                        self?.presentFailedToFetchDocumentAlert(documentName, retryAction: retry)
                    }
            }
        }
    }

    private func updateState(_ update: @escaping (inout ConfirmApplicationState) -> Void) {
        DispatchQueue.main.async {
            update(&self.state)
            self.updatableView?.updateView(self.state)
        }
    }

    private func presentFailedToFetchDocumentAlert(_ documentName: String, retryAction: @escaping () -> Void) {
        let title = Localizable.SignDocuments.ConfirmApplication.documentFetchErrorTitle
        let message = String(format: Localizable.SignDocuments.ConfirmApplication.documentFetchErrorMessage, documentName)

        alertsService.presentAlert(
            with: title,
            message: message,
            okActionCallback: {},
            retryActionCallback: retryAction
        )
    }
}

private extension Array where Element == LoadableDocument {
    var isNotLoadingAnyDocument: Bool {
        return firstIndex(where: { $0.isLoading }) == nil
    }
    
    func name(for id: String) -> String? {
        return first(where: { $0.document.id == id })?.document.name
    }
    
    mutating func updateLoading(for id: String, isLoading: Bool) {
        if let index = firstIndex(where: { $0.document.id == id }) {
            self[index].isLoading = isLoading
        }
    }
}
