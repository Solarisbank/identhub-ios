//
//  ScanDocumentType.swift
//  IdentHubSDK
//

import UIKit
import FourthlineCore

struct ScanDocumentType {

    /// Document name: passport, id-card, etc
    let name: String

    /// Document logo image
    let logo: UIImage

    /// Type of the document
    let type: DocumentType
}
