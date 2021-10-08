//
//  FinishIdentificationViewModel.swift
//  IdentHubSDK
//

import Foundation

/// ViewModel which supports finish identification view controller.
final internal class FinishIdentificationViewModel: NSObject, DocumentDownloadableViewModel {

    var verificationService: VerificationService

    var flowCoordinator: BankIDCoordinator

    /// - SeeAlso: DocumentDownloadable.documents
    var documents: [ContractDocument] = []

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

    // Finish the identification.
    func finish() {
        flowCoordinator.perform(action: .close)
    }
}
