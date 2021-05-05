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

        if let url = data.videoUrl {
            kycInfo.selfie?.videoUrl = url
        } else {
            kycInfo.selfie?.videoUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("selfieVideo.mp4")
        }
    }

    // MARK: - Filling with Document Result Data
    // Please note that type, number, issueDate and expirationDate should be set separately as part of user input if auto-scanning couldn't be done.
    func update(with data: DocumentScannerResult, for documentType: DocumentType) {
        if kycInfo.document == nil {
            kycInfo.document = Document()
        }

        kycInfo.document?.type = documentType

        mrzInfo = data.mrzInfo
        if let mrzInfo = data.mrzInfo as? MRTDMRZInfo {
            update(with: mrzInfo)
        }

        if let url = data.videoUrl {
            kycInfo.selfie?.videoUrl = url
        } else {
            kycInfo.document?.videoUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("documentVideo.mp4")
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

    func update(person data: PersonData) {
        kycInfo.provider.name = "Fourthline"
        kycInfo.provider.clientNumber = data.personUID

        kycInfo.person.firstName = data.firstName
        kycInfo.person.lastName = data.lastName
        kycInfo.person.nationalityCode = data.nationality
        kycInfo.person.birthDate = data.birthDate

        if data.gender == "male" {
            kycInfo.person.gender = .male
        } else if data.gender == "female" {
            kycInfo.person.gender = .female
        } else {
            kycInfo.person.gender = .undefined
        }
    }
}

// MARK: - Private Zone

private extension KYCContainer {

    private func update(with mrzInfo: MRTDMRZInfo) {
        kycInfo.document?.expirationDate = mrzInfo.expirationDate
        kycInfo.document?.number = mrzInfo.documentNumber

        kycInfo.person.firstName = mrzInfo.firstNames.joined(separator: " ")
        kycInfo.person.lastName = mrzInfo.lastNames.joined(separator: " ")
        kycInfo.person.gender = mrzInfo.gender
        kycInfo.person.nationalityCode = mrzInfo.nationality
        kycInfo.person.birthDate = mrzInfo.birthDate
    }
}
