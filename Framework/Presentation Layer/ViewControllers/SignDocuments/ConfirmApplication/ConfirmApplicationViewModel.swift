//
//  ConfirmApplicationViewModel.swift
//  IdentHubSDK
//

import Foundation

final internal class ConfirmApplicationViewModel: NSObject, DocumentDownloadableViewModel {

    var verificationService: VerificationService

    var flowCoordinator: BankIDCoordinator

    /// - SeeAlso: DocumentDownloadable.documents
    var documents: [Document] = []

    /// - SeeAlso: DocumentDownloadable.documentDelegate
    weak var documentDelegate: DocumentReceivable?

    init(flowCoordinator: BankIDCoordinator, delegate: DocumentReceivable, verificationService: VerificationService) {
        self.flowCoordinator = flowCoordinator
        self.documentDelegate = delegate
        self.verificationService = verificationService
        super.init()
        checkDocumentsAvailability()
    }

    // MARK: Methods

    /// Move to signing documents.
    func signDocuments() {
        flowCoordinator.perform(action: .signDocuments(step: .sign))
    }
}
