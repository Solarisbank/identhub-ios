//
//  DocumentScannerViewModel.swift
//  IdentHubSDK
//

import UIKit
import FourthlineCore

/// Identifier of the document type table cells
let documentTypeCellID = "documentTypeCellID"

/// Document scanner view model
/// Class used for saving scanned data
final class DocumentPickerViewModel: NSObject {

    // MARK: - Properties -
    private var flowCoordinator: FourthlineIdentCoordinator
    private var documentsContent: [ScanDocumentType]
    private var documentTypeDDM: DocumentTypesDDM?
    private var selectedDocument: DocumentType? {
        didSet {
            updateButtons?()
        }
    }

    var updateButtons: (() -> Void)?

    /// Init method with flow coordinator
    /// - Parameter flowCoordinator: identification process flow coordinator
    init(flowCoordinator: FourthlineIdentCoordinator) {
        self.flowCoordinator = flowCoordinator
        self.documentsContent = DocumentPickerViewModel.buildDocumentsContent()
    }

    // MARK: - Public methods -

    func configureDocumentsTable(for table: UITableView) {

        documentTypeDDM = DocumentTypesDDM(documentsContent, output: self)

        let cellNib = UINib(nibName: "DocumentTypeCell", bundle: Bundle(for: DocumentPickerViewModel.self))

        table.register(cellNib, forCellReuseIdentifier: documentTypeCellID)

        table.dataSource = documentTypeDDM
        table.delegate = documentTypeDDM
    }

    func obtainTableHeight() -> CGFloat {
        CGFloat(documentsContent.count * 110 + 25)
    }

    func startDocumentScanner() {
        guard let type = selectedDocument else { return }

        flowCoordinator.perform(action: .documentScanner(type: type))
    }

    func dismissScanner() {
        flowCoordinator.perform(action: .quit)
    }
}

// MARK: - Internal methods -
extension DocumentPickerViewModel {

    static func buildDocumentsContent () -> [ScanDocumentType] {

        let passportDocument = ScanDocumentType(name: Localizable.DocumentScanner.passport, logo: UIImage(named: "passport_logo_icon", in: Bundle(for: Self.self), compatibleWith: nil)!, type: .passport)
        let idCard = ScanDocumentType(name: Localizable.DocumentScanner.idCard, logo: UIImage(named: "idcard_logo_icon", in: Bundle(for: Self.self), compatibleWith: nil)!, type: .idCard)

        return [passportDocument, idCard]
    }
}

extension DocumentPickerViewModel: StepsProgressViewDataSource {

    func stepsCount() -> Int {
        4
    }

    func currentStep() -> Int {
        FourthlineSteps.document.rawValue
    }
}

extension DocumentPickerViewModel: DocumentTypesDDMDelegate {

    func didSelectDocument(with type: DocumentType) {
        selectedDocument = type
    }
}
