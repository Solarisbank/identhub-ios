//
//  KYCContainer.swift
//  IdentHubSDK
//

import UIKit
import FourthlineKYC
import FourthlineVision
import FourthlineCore
import CoreLocation

final class KYCContainer {
    static let shared = KYCContainer()
    private init() {}

    let kycInfo: KYCInfo = KYCInfo()
    private var mrzInfo: MRZInfo?

    // MARK: - Filling with Selfie Result Data
    func update(with data: SelfieScannerResult) {
        kycInfo.selfie = SelfieAttachment()
        kycInfo.selfie?.image = data.image.full
        kycInfo.selfie?.location = data.metadata.location
        kycInfo.selfie?.timestamp = data.metadata.timestamp
        kycInfo.selfie?.videoUrl = data.videoUrl
    }

    // MARK: - Filling with Document Result Data
    // Please note that type, number, issueDate and expirationDate should be set separately as part of user input if auto-scanning couldn't be done.
    func update(with data: DocumentScannerResult, for documentType: DocumentType) {
        if kycInfo.document == nil {
            kycInfo.document = Document()
        }

        kycInfo.document?.videoUrl = data.videoUrl
        kycInfo.document?.type = documentType

        mrzInfo = data.mrzInfo
        if let mrzInfo = data.mrzInfo as? MRTDMRZInfo {
            update(with: mrzInfo)
        }
    }

    // MARK: - Filling with Document Step Result Data
    func update(with data: DocumentScannerStepResult) {
        if kycInfo.document == nil {
            kycInfo.document = Document()
        }

        let attachment = DocumentAttachment()
        attachment.fileSide = data.metadata.fileSide
        attachment.isAngled = data.metadata.isAngled
        attachment.image = data.image.full
        attachment.timestamp = data.metadata.timestamp
        attachment.location = data.metadata.location
        kycInfo.document?.images.append(attachment)
    }

    func removeDocumentData() {
        kycInfo.document = nil
    }

    func update(with documentNumber: String) {
        kycInfo.document?.number = documentNumber
    }

    func update(with dateOfIssue: Date?) {
        kycInfo.document?.issueDate = dateOfIssue
    }

    func update(of expireDate: Date?) {
        kycInfo.document?.expirationDate = expireDate
    }

    func update(location: CLLocation) {
        kycInfo.metadata?.location = location
    }
}

// MARK: - Private Zone
private extension KYCContainer {

    func update(with mrzInfo: MRTDMRZInfo) {
        kycInfo.document?.expirationDate = mrzInfo.expirationDate
        kycInfo.document?.number = mrzInfo.documentNumber

        kycInfo.person.firstName = mrzInfo.firstNames.joined(separator: " ")
        kycInfo.person.lastName = mrzInfo.lastNames.joined(separator: " ")
        kycInfo.person.gender = mrzInfo.gender
        kycInfo.person.nationalityCode = mrzInfo.nationality
        kycInfo.person.birthDate = mrzInfo.birthDate
    }
}
