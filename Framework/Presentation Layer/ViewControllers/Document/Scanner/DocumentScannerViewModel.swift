//
//  DocumentScannerViewModel.swift
//  IdentHubSDK
//

import UIKit
import FourthlineCore
import FourthlineVision

final class DocumentScannerViewModel: NSObject {

    // MARK: - Attributes -
    var documentType: DocumentType
    private var flowCoordinator: FourthlineIdentCoordinator

    // MARK: - Init methods -
    init(_ documentType: DocumentType, flowCoordinator: FourthlineIdentCoordinator) {
        self.documentType = documentType
        self.flowCoordinator = flowCoordinator

        super.init()

        cleanData()
    }

    // MARK: - Public methods -

    /// Method returns scanned document type
    /// - Returns: enum value of the type
    func scannedType() -> DocumentType {
        documentType
    }

    /// Update document scan result in KYC container
    /// - Parameter result: scanned result
    func updateResult(_ result: DocumentScannerResult) {
        KYCContainer.shared.update(with: result, for: documentType)
        flowCoordinator.perform(action: .documentInfo)
    }

    /// Save document result to the KYC container
    /// - Parameter stepResult: final document result
    func saveResult(_ stepResult: DocumentScannerStepResult) {
        KYCContainer.shared.update(with: stepResult)
    }

    /// Method cleared documents data in KYC container
    func cleanData() {
        KYCContainer.shared.removeDocumentData()
    }
}
