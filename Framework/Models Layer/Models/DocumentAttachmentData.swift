//
//  DocumentAttachmentData.swift
//  IdentHubSDK
//

import Foundation
import UIKit
import MapKit
import FourthlineCore
import FourthlineKYC

struct DocumentAttachmentData {

    /// Document stored image name. Used for loading image data from disk
    let imageName: String

    /// Document file side
    let fileSide: FileSide

    /// Document image is taken at an angle.
    let isAngled: Bool

    /// Document image timestamp
    let timeStamp: Date

    /// Location where the document image was taken
    let location: CLLocation

    // MARK: - Init methods -

    /// Init document attachment data object from the Fourthline document attachment object
    /// - Parameter attachment: attachment object
    init(attachment: DocumentAttachment) {

        self.fileSide = attachment.fileSide
        self.isAngled = attachment.isAngled
        self.timeStamp = attachment.timestamp ?? Date()
        self.location = attachment.location ?? CLLocation()
        self.imageName = "documentScan_\(fileSide.rawValue)_\(isAngled ? "tilted" : "straight")"
    }

    /// Init document attachment data from stored Data object
    /// - Parameter data: stored data
    /// - Throws: Method throws unarchiving attribute values error
    init?(data: Data) throws {
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)

        defer {
            unarchiver.finishDecoding()
        }

        guard let time = unarchiver.decodeObject(of: NSDate.self, forKey: CodingKeys.timeStamp.rawValue) as Date? else { return nil }
        guard let locationData = unarchiver.decodeObject(forKey: CodingKeys.location.rawValue) as? Data else { return nil }
        guard let imagePath = unarchiver.decodeObject(forKey: CodingKeys.imageName.rawValue) as? String else { return nil }

        self.location = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(locationData) as? CLLocation ?? CLLocation()
        self.fileSide = FileSide(rawValue: unarchiver.decodeInteger(forKey: CodingKeys.fileSide.rawValue)) ?? .front
        self.isAngled = unarchiver.decodeBool(forKey: CodingKeys.isAngled.rawValue)
        self.timeStamp = time
        self.imageName = imagePath
    }

    // MARK: - Public methods -

    /// Method encoded object attributes to the Data
    /// - Returns: Encoded Data object
    func encode() -> Data {
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)

        archiver.encode(fileSide.rawValue, forKey: CodingKeys.fileSide.rawValue)
        archiver.encode(isAngled, forKey: CodingKeys.isAngled.rawValue)
        archiver.encode(timeStamp, forKey: CodingKeys.timeStamp.rawValue)
        archiver.encode(imageName, forKey: CodingKeys.imageName.rawValue)

        do {
            let locationData = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: false)

            archiver.encode(locationData, forKey: CodingKeys.location.rawValue)
        } catch {
            print("Error with coding location data: \(error.localizedDescription)")
        }

        archiver.finishEncoding()

        return archiver.encodedData
    }
}

private extension DocumentAttachmentData {

    /// Coding document data attributes keys
    enum CodingKeys: String, CodingKey {

        case imageName = "imageName"
        case fileSide = "fileSide"
        case isAngled = "isAngled"
        case timeStamp = "timeStamp"
        case location = "location"
    }
}
