//
//  ConfirmApplicationViewModel.swift
//  IdentHubSDK
//

import Foundation

final internal class ConfirmApplicationViewModel: NSObject, DocumentDownloadableViewModel {

    var verificationService: VerificationService

    private(set) weak var flowCoordinator: BankIDCoordinator?
    
    private var identMethod: IdentificationStep?

    /// - SeeAlso: DocumentDownloadable.documents
    var documents: [ContractDocument] = []

    /// - SeeAlso: DocumentDownloadable.documentDelegate
    weak var documentDelegate: DocumentReceivable?
    
    var hasTermsAndConditionsLink: Bool {
        identMethod == .bankIBAN
    }

    init(flowCoordinator: BankIDCoordinator, appDependencies: AppDependencies) {
        self.flowCoordinator = flowCoordinator
        self.verificationService = appDependencies.verificationService
        self.identMethod = appDependencies.sessionInfoProvider.identificationStep
        super.init()
    }

    // MARK: Methods
    
    /// Method fetched documents list for signing
    func loadDocuments() {
        checkDocumentsAvailability()
    }

    /// Move to signing documents.
    func signDocuments() {
        flowCoordinator?.perform(action: .signDocuments(step: .sign))
    }
    
    /// Method defines if progress view should be invisible
    /// - Returns: bool status of progress visibility
    func isInvisibleProgress() -> Bool {
        return ( identMethod == .fourthlineSigning )
    }
}
