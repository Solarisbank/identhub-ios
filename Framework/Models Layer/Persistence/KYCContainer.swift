//
//  KYCContainer.swift
//  IdentHubSDK
//

import UIKit
import FourthlineKYC
import FourthlineVision
import FourthlineCore
import CoreLocation

/// URL of the stored selfie full image location
/// Used for restoring identification session
let selfieFullImagePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("selfieFullImage.jpeg")

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

        storeSelfie(result: data)
    }

    // MARK: - Filling with Document Result Data

    func update(with data: DocumentScannerResult, for documentType: DocumentType) {
        if kycInfo.document == nil {
            kycInfo.document = Document()
        }

        kycInfo.document?.type = documentType

        mrzInfo = data.mrzInfo
        // Please note that type, number, issueDate and expirationDate should be set separately as part of user input if MRZ data is nil. It means document scanner didn't recognized proper data from document.
        if let mrzInfo = data.mrzInfo as? MRTDMRZInfo {
            update(with: mrzInfo)
            updatePersonData(with: mrzInfo)
        }

        if let url = data.videoUrl {
            kycInfo.document?.videoUrl = url
        }

        storeDocumentData()
    }

    // MARK: - Filling with Document Step Result Data

    /// Method filled kyc document object attributes with info from scanned document
    /// - Parameter data: scanned document info
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

        saveDocumentImage(attachment: attachment)
    }

    /// Method removed scanned document information and zip file url
    func removeDocumentData() {
        kycInfo.document = nil
        SessionStorage.deleteObject(for: StoredKeys.documentData.rawValue)
        SessionStorage.deleteObject(for: StoredKeys.kycZipData.rawValue)
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
        if kycInfo.metadata == nil {
            kycInfo.metadata = DeviceMetadata()
        }

        kycInfo.metadata?.location = location
    }

    /// Func runs storing document with updated data process again
    func updateDocumentData() {
        storeDocumentData()
    }

    /// Method filled identificated person data loaded from server
    /// - Parameter data: person detail
    func update(person data: PersonData) {
        kycInfo.provider.name = "SolarisBankCanB"
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

        setContacts(data: data)
        storePersonalData(data: data)
    }

    /// Run previous session KYC data restoration
    func restoreData() {

        restorePersonData()
        restoreSelfieData()
        restoreDocumentData()
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

// MARK: - Personal data store/load -

private extension KYCContainer {

    private func setContacts(data: PersonData) {

        if kycInfo.contacts == nil {
            kycInfo.contacts = Contacts()
        }

        kycInfo.contacts?.mobile = data.mobileNumber
        kycInfo.contacts?.email = data.email
    }

    private func storePersonalData(data: PersonData) {

        do {
            let personData = try JSONEncoder().encode(data)
            SessionStorage.updateValue(personData, for: StoredKeys.personData.rawValue)
        } catch {
            print("Error with encoding personal data: \(error.localizedDescription)")
        }
    }

    private func restorePersonData() {
        guard let personData = obtainStoredPresonData() else { return }

        update(person: personData)
    }

    private func updatePersonData(with mrzInfo: MRTDMRZInfo) {
        guard var personData = obtainStoredPresonData() else { return }

        personData.update(with: mrzInfo)

        storePersonalData(data: personData)
    }

    private func obtainStoredPresonData() -> PersonData? {

        guard let personData = SessionStorage.obtainValue(for: StoredKeys.personData.rawValue) as? Data else { return nil }

        do {
            let personData = try JSONDecoder().decode(PersonData.self, from: personData)
            return personData
        } catch {
            print("Error with decoding personal data: \(error.localizedDescription)")
        }

        return nil
    }
}

// MARK: - Selfie data store/load -

private extension KYCContainer {

    private func storeSelfie(result: SelfieScannerResult) {

        do {
            let data = result.image.full.jpegData(compressionQuality: 1.0)
            try data?.write(to: selfieFullImagePath)

            SessionStorage.updateValue(result.metadata.timestamp, for: StoredKeys.SelfieData.timestamp.rawValue)
            SessionStorage.deleteObject(for: StoredKeys.kycZipData.rawValue)

            if let location = result.metadata.location,
               let locationData = try? NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: false) {
                SessionStorage.updateValue(locationData, for: StoredKeys.SelfieData.location.rawValue)
            }

            if let videoName = result.videoUrl?.lastPathComponent {
                SessionStorage.updateValue(videoName, for: StoredKeys.SelfieData.videoURL.rawValue)
            }

            SessionStorage.updateValue(true, for: StoredKeys.selfieData.rawValue)
        } catch {
            print(error.localizedDescription)
        }
    }

    private func restoreSelfieData() {

        if let selfieData = SessionStorage.obtainValue(for: StoredKeys.selfieData.rawValue) as? Bool, selfieData {
            let selfieStoredResult = SelfieAttachment()

            let videoName = SessionStorage.obtainValue(for: StoredKeys.SelfieData.videoURL.rawValue) as! String

            selfieStoredResult.image = UIImage(contentsOfFile: selfieFullImagePath.relativePath)
            selfieStoredResult.timestamp = SessionStorage.obtainValue(for: StoredKeys.SelfieData.timestamp.rawValue) as? Date
            selfieStoredResult.videoUrl = FileManager.default.temporaryDirectory.appendingPathComponent(videoName)

            if let locationData = SessionStorage.obtainValue(for: StoredKeys.SelfieData.location.rawValue) as? Data {
                do {
                    selfieStoredResult.location = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(locationData) as? CLLocation
                    self.update(location: selfieStoredResult.location!)
                } catch {
                    print(error.localizedDescription)
                }
            }

            kycInfo.selfie = selfieStoredResult
        }
    }
}

// MARK: - Documents data store/load -

private extension KYCContainer {

    /// Method stored scanned document attachment image to the disk for session storage
    /// - Parameter attachment: scanned document attachment
    private func saveDocumentImage(attachment: DocumentAttachment) {

        let documentImageName = "documentScan_\(attachment.fileSide.rawValue)_\(attachment.isAngled ? "tilted" : "straight").jpeg"
        let documentImagePath = NSTemporaryDirectory() + documentImageName
        let documentImageURL = URL(fileURLWithPath: documentImagePath)

        if let data = attachment.image?.jpegData(compressionQuality: 1.0) {

            do {
                try data.write(to: documentImageURL)
            } catch {
                print("Error with saving document image data: \(error.localizedDescription)")
            }
        }
    }

    /// Method stored document data to the session storage
    private func storeDocumentData() {
        guard let document = kycInfo.document else { return }

        let documentData = DocumentData(document: document)

        SessionStorage.updateValue(documentData.encode(), for: StoredKeys.documentData.rawValue)
        SessionStorage.deleteObject(for: StoredKeys.kycZipData.rawValue)
    }

    /// Method restored scanned document from previous session
    private func restoreDocumentData() {
        guard let storedData = SessionStorage.obtainValue(for: StoredKeys.documentData.rawValue) as? Data else { return }

        do {
            if let documentData = try DocumentData(data: storedData) {

                update(documentData: documentData)
            }
        } catch {
            print("Error with unarchiving kyc document data: \(error.localizedDescription)")
        }
    }

    /// Method filled kyc info document object with restored document data
    /// - Parameter documentData: resotred document data object
    private func update(documentData: DocumentData) {

        if kycInfo.document == nil {
            kycInfo.document = Document()
        }

        kycInfo.document?.type = documentData.type
        kycInfo.document?.videoUrl = documentData.videoURL
        kycInfo.document?.number = documentData.number
        kycInfo.document?.expirationDate = documentData.expirationDate
        kycInfo.document?.issueDate = documentData.issueDate

        for attachmentData in documentData.images {

            let attachment = DocumentAttachment()
            attachment.fileSide = attachmentData.fileSide
            attachment.isAngled = attachmentData.isAngled
            attachment.timestamp = attachmentData.timeStamp
            attachment.location = attachmentData.location

            let imagePath = NSTemporaryDirectory() + attachmentData.imageName
            if let image = UIImage(contentsOfFile: imagePath) {
                attachment.image = image
            }

            kycInfo.document?.images.append(attachment)
        }
    }
}
