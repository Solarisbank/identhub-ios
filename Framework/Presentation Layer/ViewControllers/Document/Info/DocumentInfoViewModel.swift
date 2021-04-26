//
//  DocumentInfoViewModel.swift
//  IdentHubSDK
//

import UIKit
import FourthlineCore

/// Identifier of the document type table cells
let documentInfoCellID = "documentInfoCellID"

final class DocumentInfoViewModel: BaseFourthlineViewModel {

    // MARK: - Private attributes -
    private var infoContent: [DocumentItemInfo] = []
    private var tableDDM: DocumentInfoDDM?

    var didUpdatedContent: ((Bool) -> Void)?

    // MARK: - Public methods -

    func configure(of table: UITableView) {
        infoContent = buildContent()
        tableDDM = DocumentInfoDDM(infoContent, output: self)

        let cellNib = UINib(nibName: "DocumentItemInfoCell", bundle: Bundle(for: DocumentItemInfoCell.self))

        table.register(cellNib, forCellReuseIdentifier: documentInfoCellID)

        table.dataSource = tableDDM

        validateContent()
    }

    func didTriggerBack() {
        coordinator.perform(action: .documentPicker)
    }

    func didTriggerContinue() {
        updateKYC()
        coordinator.perform(action: .location)
    }
}

extension DocumentInfoViewModel: StepsProgressViewDataSource {

    func currentStep() -> Int {
        FourthlineSteps.confirm.rawValue
    }
}

extension DocumentInfoViewModel: DocumentInfoDDMDelegate {

    func didUpdatedContent(_ content: DocumentItemInfo) {
        infoContent[content.type.rawValue] = content

        validateContent()
    }
}

// MARK: - Internal methods -
extension DocumentInfoViewModel {

    func buildContent() -> [DocumentItemInfo] {
        typealias InfoText = Localizable.DocumentScanner.Information

        let document = KYCContainer.shared.kycInfo.document

        let docNumber = DocumentItemInfo(title: InfoText.docNumber, content: document?.number ?? "", type: .number)
        let issueDate = DocumentItemInfo(title: InfoText.birth, content: "", type: .issueDate)
        let expireDate = DocumentItemInfo(title: InfoText.expire, content: document?.expirationDate?.defaultDateString() ?? "", type: .expireDate)

        return [docNumber, issueDate, expireDate]
    }

    private func validateContent() {
        let isValidContent = infoContent.filter { $0.content.isEmpty }

        didUpdatedContent?(isValidContent.isEmpty)
    }

    private func updateKYC() {
        infoContent.forEach { info in
            switch info.type {
            case .number:
                KYCContainer.shared.update(with: info.content)
            case .issueDate:
                KYCContainer.shared.update(with: info.content.dateFromString())
            case .expireDate:
                KYCContainer.shared.update(of: info.content.dateFromString())
            }
        }
    }
}
