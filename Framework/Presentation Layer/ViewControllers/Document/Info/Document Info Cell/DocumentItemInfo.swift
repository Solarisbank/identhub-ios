//
//  DocumentItemInfo.swift
//  IdentHubSDK
//

import UIKit

enum DocumentInfoType: Int {
    case number = 0, issueDate, expireDate
}

struct DocumentItemInfo {

    /// Item title
    var title: String

    /// Item content
    var content: String

    /// Type of the document info item
    var type: DocumentInfoType

    /// Prefilled date value
    var prefilledDate: Date?
}
