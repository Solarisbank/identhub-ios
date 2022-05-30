//
//  DocumentInfoViewModel.swift
//  IdentHubSDK
//

import UIKit
import FourthlineCore
import FourthlineKYC

/// Identifier of the document info item table cells
let documentInfoCellID = "documentInfoCellID"

final class DocumentInfoViewModel: BaseFourthlineViewModel {

    // MARK: - Private attributes -
    private var infoContent: [DocumentItemInfo] = []
    private var tableDDM: DocumentInfoDDM?

    var didUpdatedContent: ((Bool) -> Void)?
    var reloadTable: (() -> Void)?

    // MARK: - Public methods -

    func configure(of table: UITableView) {
        infoContent = buildContent()
        tableDDM = DocumentInfoDDM(infoContent, output: self)

        let cellNib = UINib(nibName: "DocumentItemInfoCell", bundle: Bundle(for: DocumentItemInfoCell.self))

        table.register(cellNib, forCellReuseIdentifier: documentInfoCellID)

        table.dataSource = tableDDM

        validateContent()
        reloadTable?()
    }

    func didTriggerBack() {
        coordinator?.perform(action: .documentPicker)
    }

    func didTriggerContinue() {
        updateKYC()
        coordinator?.perform(action: .selfie)
    }
}

extension DocumentInfoViewModel: StepsProgressViewDataSource {

    func currentStep() -> Int {
        FourthlineProgressStep.confirm.rawValue
    }
}

extension DocumentInfoViewModel: DocumentInfoDDMDelegate {

    func didUpdatedContent(_ content: DocumentItemInfo) {

        switch content.type {
        case .number:
            infoContent[DocumentItemInfoType.number.rawValue] = content
        case .issueDate:
            if let date = content.content.dateFromString() {
                infoContent[DocumentItemInfoType.issueDate.rawValue] = content

                if infoContent[DocumentItemInfoType.expireDate.rawValue].prefilledDate == nil {
                    infoContent[DocumentItemInfoType.expireDate.rawValue].prefilledDate = date.addYears(10)
                }
            } else {
                infoContent[DocumentItemInfoType.issueDate.rawValue].content = ""
            }
        case .expireDate:
            if let date = content.content.dateFromString() {
                infoContent[DocumentItemInfoType.expireDate.rawValue] = content

                if infoContent[DocumentItemInfoType.issueDate.rawValue].prefilledDate == nil {
                    infoContent[DocumentItemInfoType.issueDate.rawValue].prefilledDate = date.addYears(-10)
                }
            } else {
                infoContent[DocumentItemInfoType.expireDate.rawValue].content = ""
            }
        }

        tableDDM?.updateContent(infoContent)
        reloadTable?()
        validateContent()
    }
}

// MARK: - Internal methods -

private extension DocumentInfoViewModel {

    private func buildContent() -> [DocumentItemInfo] {
        typealias InfoText = Localizable.DocumentScanner.Information

        let document = KYCContainer.shared.kycInfo.document

        let docNumber = DocumentItemInfo(title: InfoText.docNumber, content: document?.number ?? "", type: .number)
        let issueDate = DocumentItemInfo(title: InfoText.issue, content: document?.issueDate?.defaultDateString() ?? "", type: .issueDate, prefilledDate: obtainDateOfIssue(document))
        let expireDate = DocumentItemInfo(title: InfoText.expire, content: document?.expirationDate?.defaultDateString() ?? "", type: .expireDate, prefilledDate: obtainExpirationDate(document))

        return [docNumber, issueDate, expireDate]
    }

    private func obtainDateOfIssue(_ document: Document?) -> Date? {

        if let issueDate = document?.issueDate {
            return issueDate
        } else if let expireDate = document?.expirationDate {
            return expireDate.addYears(-10)
        }

        return nil
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
            case .issueDate:
                if let _ = $0.content.dateFromString() {
                    return false
                } else {
                    return true
                }
            case .expireDate:
                if let date = $0.content.dateFromString() {
                    return !date.isLaterThanOrEqualTo(Date())
                } else {
                    return true
                }
            }
        }

        didUpdatedContent?(isNotValidContent.isEmpty)
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
