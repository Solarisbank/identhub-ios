//
//  DocumentData.swift
//  IdentHubSDK
//

import Foundation
import UIKit
import MapKit
import FourthlineCore
import FourthlineKYC

struct DocumentData {

    /// Document type.
    let type: DocumentType

    /// Document string number
    let number: String

    /// Document issue date (optional).
    let issueDate: Date?

    /// Document expiration date (optional).
    let expirationDate: Date?

    /// An array of document image information.
    var images: [DocumentAttachmentData] = []

    /// Document scan video url
    let videoURL: URL

    // MARK: - Init methods -

    /// Init document data object from Fourthline Document class object
    /// - Parameter document: document object with all data
    init(document: Document) {

        self.type = document.type
        self.number = document.number ?? ""
        self.issueDate = document.issueDate
        self.expirationDate = document.expirationDate
        self.videoURL = document.videoUrl ?? URL(fileURLWithPath: "")

        for image in document.images {
            let attachment = DocumentAttachmentData(attachment: image)
            self.images.append(attachment)
        }
    }

    /// Method initialized document object with restored data
    /// - Parameter data: stored data object
    /// - Throws: Method throws errors of the unarchiving process
    init?(data: Data) throws {
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)

        defer {
            unarchiver.finishDecoding()
        }

        guard let number = unarchiver.decodeObject(forKey: CodingKeys.number.rawValue) as? String else { return nil }
        guard let videoPath = unarchiver.decodeObject(forKey: CodingKeys.videoURL.rawValue) as? String else { return nil }
        guard let attachmentsData = unarchiver.decodeObject(forKey: CodingKeys.attachments.rawValue) as? Data else { return nil }
        guard let attachments = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(attachmentsData) as? [Data] else { return nil }

        self.type = DocumentType.init(rawValue: unarchiver.decodeInteger(forKey: CodingKeys.type.rawValue)) ?? .passport
        self.issueDate = unarchiver.decodeObject(of: NSDate.self, forKey: CodingKeys.issueDate.rawValue) as Date?
        self.expirationDate = unarchiver.decodeObject(of: NSDate.self, forKey: CodingKeys.expirationDate.rawValue) as Date?
        self.number = number
        self.videoURL = URL(string: videoPath) ?? URL(string: "")!
        self.images = try attachments.compactMap { return try DocumentAttachmentData(data: $0) }
    }

    // MARK: - Public methods -

    /// Method encoded document data attributes to the Data object for storing to Session storage
    /// - Returns: encoded data
    func encode() -> Data {
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)

        archiver.encode(type.rawValue, forKey: CodingKeys.type.rawValue)
        archiver.encode(number, forKey: CodingKeys.number.rawValue)
        archiver.encode(issueDate, forKey: CodingKeys.issueDate.rawValue)
        archiver.encode(expirationDate, forKey: CodingKeys.expirationDate.rawValue)
        archiver.encode(videoURL.relativePath, forKey: CodingKeys.videoURL.rawValue)

        let attachmentsEncodedData = images.map { $0.encode() }

        do {
            let attachmentsData = try NSKeyedArchiver.archivedData(withRootObject: attachmentsEncodedData, requiringSecureCoding: false)
            archiver.encode(attachmentsData, forKey: CodingKeys.attachments.rawValue)
        } catch {
            print("Error with encoding attachments encoded data: \(error.localizedDescription)")
        }

        archiver.finishEncoding()

        return archiver.encodedData
    }
}

private extension DocumentData {

    /// Coding document data attributes keys
    enum CodingKeys: String, CodingKey {

        case type = "type"
        case number = "number"
        case issueDate = "issueDate"
        case expirationDate = "expirationDate"
        case attachments = "attachments"
        case videoURL = "videoURL"
    }
}
