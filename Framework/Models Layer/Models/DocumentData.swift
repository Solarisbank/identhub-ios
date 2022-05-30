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
    let videoRecording: VideoRecording?

    // MARK: - Init methods -

    /// Init document data object from Fourthline Document class object
    /// - Parameter document: document object with all data
    init(document: Document) {

        self.type = document.type
        self.number = document.number ?? ""
        self.issueDate = document.issueDate
        self.expirationDate = document.expirationDate
        self.videoRecording = document.videoRecording

        for image in document.images {
            let attachment = DocumentAttachmentData(attachment: image)
            self.images.append(attachment)
        }
    }
}
