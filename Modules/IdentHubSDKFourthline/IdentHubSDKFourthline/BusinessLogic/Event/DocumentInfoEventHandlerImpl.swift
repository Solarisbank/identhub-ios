//
//  DocumentInfoEventHandlerImpl.swift
//  IdentHubSDKFourthline
//

import Foundation
import UIKit
import IdentHubSDKCore
import FourthlineCore
import FourthlineKYC

/// Identifier of the document info item table cells
let documentInfoCellID = "documentInfoCellID"

internal struct DocumentInfoInput {
    let isSecondDocument: Bool
}

internal enum DocumentInfoOutput: Equatable {
    case fallBackStep
    case selfieScreen
    case instructionScreen
    case quit
}

// MARK: - Document Info event logic -

typealias DocumentInfoCallback = (DocumentInfoOutput) -> Void

final internal class DocumentInfoEventHandlerImpl<ViewController: UpdateableShowable>: EventHandler where ViewController.EventHandler == AnyEventHandler<DocumentInfoEvent>, ViewController.ViewState == DocumentInfoState {
    
    weak var updatableView: ViewController?
    
    // MARK: - Properties -
    
    private var infoContent: [DocumentItemInfo] = []
    private var tableDDM: DocumentInfoDDM?
    
    var didUpdatedContent: ((Bool) -> Void)?
    var reloadTable: (() -> Void)?
    
    private let verificationService: VerificationService
    private let alertsService: AlertsService
    private var state: DocumentInfoState
    private var input: DocumentInfoInput
    internal var colors: Colors
    private var callback: DocumentInfoCallback
    
    init(
        verificationService: VerificationService,
        alertsService: AlertsService,
        input: DocumentInfoInput,
        colors: Colors,
        callback: @escaping DocumentInfoCallback
    ) {
        self.verificationService = verificationService
        self.alertsService = alertsService
        self.input = input
        self.colors = colors
        self.callback = callback
        self.state = DocumentInfoState()
    }
    
    func handleEvent(_ event: DocumentInfoEvent) {
        switch event {
        case .configureDocumentsInfoTable(let table):
            self.configure(table)
        case .triggerContinue:
            #if !AUTOMATION
                updateKYC()
            #endif
            
            if input.isSecondDocument {
                callback(.instructionScreen)
            } else {
                callback(.selfieScreen)
            }
        case .triggerBack:
            callback(.fallBackStep)
        }
    }
    
    private func updateState(_ update: @escaping (inout DocumentInfoState) -> Void) {
        DispatchQueue.main.async {
            update(&self.state)
            self.updatableView?.updateView(self.state)
        }
    }
    
    private func configure(_ table: UITableView) {
        infoContent = buildContent()
        tableDDM = DocumentInfoDDM(infoContent, output: self, colors: colors)
        
        let cellNib = UINib(nibName: "DocumentItemInfoCell", bundle: Bundle(for: DocumentItemInfoCell.self))
        table.register(cellNib, forCellReuseIdentifier: documentInfoCellID)
        table.dataSource = tableDDM
        
        validateContent()
        updateState { state in
            state.state = .reloadTable
        }
    }
    
    func quit() {
        callback(.quit)
    }
    
}

extension DocumentInfoEventHandlerImpl: StepsProgressViewDataSource {
    
    func currentStepHightlightColor() -> UIColor {
        return colors[.secondaryAccent]
    }
    
    func currentStep() -> Int {
        FourthlineProgressStep.confirm.rawValue
    }
}

extension DocumentInfoEventHandlerImpl: DocumentInfoDDMDelegate {
    
    func didUpdatedContent(_ content: DocumentItemInfo) {
        switch content.type {
        case .number:
            infoContent[DocumentItemInfoType.number.rawValue] = content
        case .expireDate:
            infoContent[DocumentItemInfoType.expireDate.rawValue] = content
        }
        
        #if AUTOMATION
            infoContent[DocumentItemInfoType.expireDate.rawValue].content = ""
        #endif
        
        tableDDM?.updateContent(infoContent)
        updateState { state in
            state.state = .reloadTable
        }
        validateContent()
    }
}

// MARK: - Internal methods -

private extension DocumentInfoEventHandlerImpl {
    
    private func buildContent() -> [DocumentItemInfo] {
        typealias InfoText = Localizable.DocumentScanner.Information
        
        let document =  KYCContainer.shared.kycInfo.document
                
        fourthlineLog.assertWarn(document?.number != nil, "Document number is not available")
        fourthlineLog.assertWarn(document?.expirationDate != nil, "Expiration date is not available")
        
        let docNumber = DocumentItemInfo(title: InfoText.docNumber, content: document?.number ?? "", type: .number)
        let expireDate = DocumentItemInfo(title: InfoText.expire, content: document?.expirationDate?.defaultDateString() ?? "", type: .expireDate, prefilledDate: obtainExpirationDate(document))
        
        return [docNumber, expireDate]
    }
    
    private func obtainExpirationDate(_ document: Document?) -> Date? {
        if let expireDate = document?.expirationDate {
            return expireDate
        } else if let dateOfIssue = document?.issueDate {
            return dateOfIssue.addYears(10)
        }
        
        return nil
    }
    
    private func validateContent() {
        let isNotValidContent = infoContent.filter {
            switch $0.type {
            case .number:
                return $0.content.isEmpty
            case .expireDate:
                if let date = $0.content.dateFromString() {
                    return !date.isLaterThanOrEqualTo(Date())
                } else {
                    return true
                }
            }
        }
        
        updateState { state in
            state.state = .didUpdatedContent
            state.continueBtnEnable = isNotValidContent.isEmpty
        }
    }
    
    private func updateKYC() {
        infoContent.forEach { info in
            switch info.type {
            case .number:
                KYCContainer.shared.update(with: info.content)
            case .expireDate:
                KYCContainer.shared.update(of: info.content.dateFromString())
            }
        }
    }
}
