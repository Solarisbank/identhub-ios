//
//  DocumentPickerEventHandlerImpl.swift
//  IdentHubSDKFourthline
//

import UIKit
import IdentHubSDKCore
import FourthlineCore
import FourthlineKYC

/// Identifier of the document type table cells
let documentTypeCellID = "documentTypeCellID"

internal enum DocumentPickerOutput: Equatable {
    case documentScanner(type: DocumentType)
    case quit
}

internal struct DocumentPickerInput {
    var identificationStep: IdentificationStep?
    let documentsList: [SupportedDocument]?
}

// MARK: - DocumentPicker events logic - 

typealias DocumentPickerCallback = (DocumentPickerOutput) -> Void

final internal class DocumentPickerEventHandlerImpl<ViewController: UpdateableShowable>: EventHandler where ViewController.EventHandler == AnyEventHandler<DocumentPickerEvent>, ViewController.ViewState == DocumentPickerState {
    
    weak var updatableView: ViewController?
    
    // MARK: - Properties -
    
    private let verificationService: VerificationService
    private let alertsService: AlertsService
    private var state: DocumentPickerState
    private var input: DocumentPickerInput
    internal var colors: Colors
    private var storage: Storage
    private var callback: DocumentPickerCallback
    
    init(
        verificationService: VerificationService,
        alertsService: AlertsService,
        input: DocumentPickerInput,
        colors: Colors,
        storage: Storage,
        callback: @escaping DocumentPickerCallback
    ) {
        self.verificationService = verificationService
        self.alertsService = alertsService
        self.input = input
        self.colors = colors
        self.storage = storage
        self.callback = callback
        self.state = DocumentPickerState()
    }
    
    func handleEvent(_ event: DocumentPickerEvent) {
        switch event {
        case .configureDocumentsTable(let table):
            self.configureDocumentsTable(table: table)
        case .selectDocument:
            self.startDocumentScanner()
        case .quit:
            quit()
        }
    }
    
    func configureDocumentsTable(table: UITableView) {
        updateState { state in
            state.documentsContent = self.buildDocumentsContent()
            state.documentTypeDDM =  DocumentTypesDDM(state.documentsContent, self.colors, output: self)
            
            let cellNib = UINib(nibName: "DocumentTypeCell", bundle: Bundle(for: DocumentPickerEventHandlerImpl.self))
            table.register(cellNib, forCellReuseIdentifier: documentTypeCellID)
            
            table.dataSource = state.documentTypeDDM
            table.delegate = state.documentTypeDDM
            
            state.obtainTableHeight = CGFloat(state.documentsContent.count * 110)
            state.state = .loadDocument
        }
    }
    
    private func updateState(_ update: @escaping (inout DocumentPickerState) -> Void) {
        DispatchQueue.main.async {
            update(&self.state)
            self.updatableView?.updateView(self.state)
        }
    }
    
    func quit() {
        callback(.quit)
    }
    
    func startDocumentScanner() {
        updateState { state in
            guard let type = state.selectedDocument else { return }
            self.callback(.documentScanner(type: type))
        }
    }
    
}

// MARK: - Internal methods -

private extension DocumentPickerEventHandlerImpl {
    
    private func buildDocumentsContent () -> [ScanDocumentType] {
        var content: [ScanDocumentType] = []

        input.documentsList?.forEach({ supportedDocument in

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
            }
        })

        return content
    }
    
}

extension DocumentPickerEventHandlerImpl: StepsProgressViewDataSource {
    
    func currentStepHightlightColor() -> UIColor {
        return colors[.secondaryAccent]
    }

    func currentStep() -> Int {
        FourthlineProgressStep.document.rawValue
    }
}

extension DocumentPickerEventHandlerImpl: DocumentTypesDDMDelegate {

    func didSelectDocument(with type: DocumentType) {
        updateState { state in
            state.selectedDocument = type
            state.state = .updateSelectedDocument
        }
    }
}
