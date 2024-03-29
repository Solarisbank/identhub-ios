//
//  KYCZipService.swift
//  IdentHubSDKFourthline
//

import Foundation
import FourthlineKYC
import FourthlineCore

enum KYCZipErrorType {
    case invalidDocument
    case invalidSelfie
    case invalidData
}

enum KYCZipService {
    static func createKYCZip(_ completion: @escaping((URL?, Error?) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
             kycLog.info("Creating zip file...")
            
            do {
                let zipper = Zipper()
                
                let kycZipUrl = try zipper.createZipFile(with: KYCContainer.shared.kycInfo)
                
                kycLog.info("Zip file creation success")
                DispatchQueue.main.async {
                    completion(kycZipUrl, nil)
                }
            } catch let error as ZipperError {
                kycLog.error("Zip file creation error: \(KYCZipService.text(for: error))")
                
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            } catch {
                kycLog.error("Error during zip file creation: \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }

    static func text(for zipperError: ZipperError) -> String {
        switch zipperError {
        case .kycIsNotValid:
            return Localizable.Zipper.Error.kycIsNotValid + getValidationErrors()
        case .zipExceedMaximumSize:
            return Localizable.Zipper.Error.zipExceedMaximumSize
        case .cannotCreateZip:
            return Localizable.Zipper.Error.cannotCreateZip
        case .notEnoughSpace:
            return Localizable.Zipper.Error.notEnoughSpace
        case .unknown:
            return Localizable.Zipper.Error.unknown
        @unknown default:
            return zipperError.description
        }
    }
}

extension KYCZipService {

    static func getValidationErrors() -> String {
        var errorMessage: String = ""

        let result = Set<KYCInfo.KYCInfoValidationError>(KYCContainer.shared.kycInfo.validate())
        if result.contains(.invalidAddress),
           let address = KYCContainer.shared.kycInfo.address {

            let errors = Set<Address.AddressValidationError>(address.validate())
            errorMessage.append("\n Address: \(errors.map { $0 })")
        }

        if result.contains(.invalidPerson) {
            let errors = Set<Person.PersonValidationError>(KYCContainer.shared.kycInfo.person.validate())
            errorMessage.append("\n Person: \(errors.map { $0 })")
        }

        if result.contains(.invalidSelfie),
           let selfieAttachment = KYCContainer.shared.kycInfo.selfie {

            let errors = Set<SelfieAttachment.SelfieAttachmentValidationError>(selfieAttachment.validate())
            errorMessage.append("\n SelfieAttachment: \(errors.map { $0 })")
        }

        if result.contains(.invalidProvider) {
            let errors = Set<Provider.ProviderValidationError>(KYCContainer.shared.kycInfo.provider.validate())
            errorMessage.append("\n Provider: \(errors.map { $0 })")
        }

        if result.contains(.invalidDocument),
           let document = KYCContainer.shared.kycInfo.document {

            let errors = Set<Document.DocumentValidationError>(document.validate())
            errorMessage.append("\n Document: \(errors.map { $0 })")
        }

        if result.contains(.invalidContacts) {

            let contacts = KYCContainer.shared.kycInfo.contacts
            let errors = Set<Contacts.ContactsValidationError>(contacts.validate())
            errorMessage.append("\n Contacts: \(errors.map { $0 })")
        }

        if result.contains(.invalidSecondaryDocument) {

            let secondaryDocuments = KYCContainer.shared.kycInfo.secondaryDocuments
            for doc in secondaryDocuments {
                let errors = Set<SecondaryDocument.SecondaryDocumentValidationError>(doc.validate())
                errorMessage.append("\n Secondary Document: \(errors.map { $0 })")
            }
        }

        if result.contains(.invalidDocumentsToSign) {

            let documents = KYCContainer.shared.kycInfo.documentsToSign
            for doc in documents {
                let errors = Set<FourthlineKYC.QESAttachment.QESAttachmentValidationError>(doc.validate())
                errorMessage.append("\n Document To Sign: \(errors.map { $0 })")
            }
        }

        if result.contains(.invalidTaxInfo),
           let taxInfo = KYCContainer.shared.kycInfo.taxInfo {

            let errors = Set<FourthlineKYC.TaxInfo.TaxInfoValidationError>(taxInfo.validate())
            errorMessage.append("\n Tax Info: \(errors.map { $0 })")
        }

        if result.contains(.invalidMetadata) {
            let metadata = KYCContainer.shared.kycInfo.metadata
            let errors = Set<DeviceMetadata.DeviceMetadataValidationError>(metadata.validate())
            errorMessage.append("\n DeviceMetadata: \(errors.map { $0 })")
        }
        return errorMessage.isEmpty ? Localizable.Zipper.Error.unknown : errorMessage
    }

    static func zipErrorType(for zipperError: ZipperError) -> KYCZipErrorType {

        if zipperError == .kycIsNotValid {
            let result = Set<KYCInfo.KYCInfoValidationError>(KYCContainer.shared.kycInfo.validate())

            if result.contains(.invalidDocument) {
                return .invalidDocument
            } else if result.contains(.invalidSelfie) {
                    return .invalidSelfie
            }
        }

        return .invalidData
    }
}
