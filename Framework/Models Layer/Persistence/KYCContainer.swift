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
    private var infoProvider: SessionInfoProvider?

    // MARK: - Filling with provider value -
    func update(provider: String) {
        kycInfo.provider.name = provider

        storeProvider(provider: provider)
    }

    // MARK: - Filling with Selfie Result Data
    func update(with data: SelfieScannerResult) {
        kycInfo.selfie = SelfieAttachment()
        kycInfo.selfie?.image = data.image.full
        kycInfo.selfie?.location = data.metadata.location

        // Quick fix for restoring location issues
        kycInfo.metadata.location = data.metadata.location
        
        kycInfo.selfie?.timestamp = data.metadata.timestamp
        kycInfo.selfie?.videoRecording = data.videoRecording
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

        kycInfo.document?.videoRecording = data.videoRecording
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
    }

    /// Method removed scanned document information and zip file url
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
        kycInfo.metadata.location = location
    }

    func update(ipAddress: String) {
        kycInfo.metadata.ipAddress = ipAddress

        storeIPAddress(ipAddress: ipAddress)
    }

    /// Method filled identificated person data loaded from server
    /// - Parameter data: person detail
    func update(person data: PersonData) {
        kycInfo.provider.clientNumber = data.personUID

        fillPersonData(data)
        fillPersonAddressData(data)

        setContacts(data: data)
        storePersonalData(data: data)
    }

    /// Run previous session KYC data restoration
    func restoreData(_ infoProvider: SessionInfoProvider) {

        self.infoProvider = infoProvider

        restoreProvider()
        restoreIPAddress()
        restorePersonData()
    }
    
    /// Method clears stored person data
    func clearPresonData() {
        kycInfo.person = Person()
        kycInfo.address = nil
        kycInfo.contacts = Contacts()
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
        kycInfo.person.birthDate = mrzInfo.birthDate

        if CountryCodes.isSupported(country: mrzInfo.nationality) {
            kycInfo.person.nationalityCode = mrzInfo.nationality
        }
    }

    private func fillPersonData(_ data: PersonData) {

        kycInfo.person.firstName = data.firstName
        kycInfo.person.lastName = data.lastName
        kycInfo.person.birthDate = data.birthDate
        kycInfo.person.birthPlace = data.birthPlace

        if CountryCodes.isSupported(country: data.nationality) {
            kycInfo.person.nationalityCode = data.nationality
        }

        switch data.gender {
        case .male:
            kycInfo.person.gender = .male
        case .female:
            kycInfo.person.gender = .female
        case .unknown:
            kycInfo.person.gender = .unknown
        }
    }

    private func fillPersonAddressData(_ personData: PersonData) {

        if kycInfo.address == nil {
            kycInfo.address = Address()
        }

        kycInfo.address?.city = personData.address.city
        kycInfo.address?.countryCode = personData.address.country
        kycInfo.address?.street = personData.address.street
        kycInfo.address?.postalCode = personData.address.postalCode
        
        let streetNumberData = personData.address.parseStreetNumber()
        kycInfo.address?.streetNumber = streetNumberData.number
        kycInfo.address?.streetNumberSuffix = streetNumberData.suffix
    }
}

// MARK: - Personal data store/load -

private extension KYCContainer {

    private func setContacts(data: PersonData) {

        kycInfo.contacts.mobile = data.mobileNumber
        kycInfo.contacts.email = data.email
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

        infoProvider?.documentsList = personData.supportedDocuments
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

// MARK: - Provider data store/load -

private extension KYCContainer {

    private func storeProvider(provider: String) {
        SessionStorage.updateValue(provider, for: StoredKeys.providerData.rawValue)
    }

    private func restoreProvider() {
        guard let provider = SessionStorage.obtainValue(for: StoredKeys.providerData.rawValue) as? String else { return }

        kycInfo.provider.name = provider
    }
}

// MARK: - IPAddress data store/load -

private extension KYCContainer {

    private func storeIPAddress(ipAddress: String) {
        SessionStorage.updateValue(ipAddress, for: StoredKeys.ipAddressData.rawValue)
    }

    private func restoreIPAddress() {
        guard let ipAddress = SessionStorage.obtainValue(for: StoredKeys.ipAddressData.rawValue) as? String else { return }

        update(ipAddress: ipAddress)
    }
}

// MARK: - Documents data store/load -

private extension KYCContainer {

    /// Method filled kyc info document object with restored document data
    /// - Parameter documentData: resotred document data object
    private func update(documentData: DocumentData) {

        if kycInfo.document == nil {
            kycInfo.document = Document()
        }

        kycInfo.document?.type = documentData.type
        kycInfo.document?.videoRecording = documentData.videoRecording
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
