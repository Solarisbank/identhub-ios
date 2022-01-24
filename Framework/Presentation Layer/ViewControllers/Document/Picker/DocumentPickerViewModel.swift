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
final class DocumentPickerViewModel: BaseFourthlineViewModel {

    // MARK: - Properties -
    private var documentsContent: [ScanDocumentType] = []
    private var documentTypeDDM: DocumentTypesDDM?
    private var infoProvider: SessionInfoProvider
    private var selectedDocument: DocumentType? {
        didSet {
            updateButtons?()
        }
    }

    var updateButtons: (() -> Void)?

    // MARK: - Init methods -

    init(_ coordinator: FourthlineIdentCoordinator, infoProvider: SessionInfoProvider) {

        self.infoProvider = infoProvider
        super.init(coordinator)
    }

    // MARK: - Public methods -

    func configureDocumentsTable(for table: UITableView) {
        documentsContent = buildDocumentsContent()
        documentTypeDDM = DocumentTypesDDM(documentsContent, output: self)

        let cellNib = UINib(nibName: "DocumentTypeCell", bundle: Bundle(for: DocumentPickerViewModel.self))

        table.register(cellNib, forCellReuseIdentifier: documentTypeCellID)

        table.dataSource = documentTypeDDM
        table.delegate = documentTypeDDM
    }

    func obtainTableHeight() -> CGFloat {
        CGFloat(documentsContent.count * 110)
    }

    func startDocumentScanner() {
        guard let type = selectedDocument else { return }

        coordinator.perform(action: .documentScanner(type: type))
    }
}

// MARK: - Internal methods -
extension DocumentPickerViewModel {

    func buildDocumentsContent () -> [ScanDocumentType] {
        var content: [ScanDocumentType] = []

        infoProvider.documentsList?.forEach({ supportedDocument in

            switch supportedDocument.type {
            case .passport:
                let passportDocument = ScanDocumentType(name: Localizable.DocumentScanner.passport, logo: UIImage(named: "passport_logo_icon", in: Bundle(for: Self.self), compatibleWith: nil)!, type: .passport)
                content.append(passportDocument)
            case .idCard:
                let idCard = ScanDocumentType(name: Localizable.DocumentScanner.idCard, logo: UIImage(named: "idcard_logo_icon", in: Bundle(for: Self.self), compatibleWith: nil)!, type: .idCard)
                content.append(idCard)
            case .driversLicense:
                _ = ScanDocumentType(name: supportedDocument.type.rawValue, logo: UIImage(named: "idcard_logo_icon", in: Bundle(for: Self.self), compatibleWith: nil)!, type: .driversLicense)
            case .residencePermit:
                _ = ScanDocumentType(name: supportedDocument.type.rawValue, logo: UIImage(named: "permit_document_logo_icon", in: Bundle(for: Self.self), compatibleWith: nil)!, type: .residencePermit)
            case .paperId:
                let paperID = ScanDocumentType(name: Localizable.DocumentScanner.paperID, logo: UIImage(named: "passport_logo_icon", in: Bundle(for: Self.self), compatibleWith: nil)!, type: .paperId)
                content.append(paperID)
            case .frenchIdCard:
                let frenchIDCard = ScanDocumentType(name: supportedDocument.type.rawValue, logo: UIImage(named: "idcard_logo_icon", in: Bundle(for: Self.self), compatibleWith: nil)!, type: .frenchIdCard)
                content.append(frenchIDCard)
            case .dutchDriversLicense:
                _ = ScanDocumentType(name: supportedDocument.type.rawValue, logo: UIImage(named: "idcard_logo_icon", in: Bundle(for: Self.self), compatibleWith: nil)!, type: .dutchDriversLicense)
            }
        })

        return content
    }
}

extension DocumentPickerViewModel: StepsProgressViewDataSource {

    func currentStep() -> Int {
        FourthlineProgressStep.document.rawValue
    }
}

extension DocumentPickerViewModel: DocumentTypesDDMDelegate {

    func didSelectDocument(with type: DocumentType) {
        selectedDocument = type
    }
}
