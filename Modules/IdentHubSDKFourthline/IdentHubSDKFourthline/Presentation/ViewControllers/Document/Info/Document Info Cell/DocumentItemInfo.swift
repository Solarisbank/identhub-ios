//
//  DocumentItemInfo.swift
//  IdentHubSDKFourthline
//

import UIKit

enum DocumentItemInfoType: Int {
    case number = 0, expireDate
}

enum DocumentItemInfoStatus {
    case empty, valid, pastDate
    
    var description: String {
        switch self {
        case .empty:
            return Localizable.DocumentScanner.Information.enterData
        case .valid:
            return Localizable.DocumentScanner.Information.confirmData
        case .pastDate:
            return Localizable.DocumentScanner.Information.expireDateMessage
        }
    }
}

struct DocumentItemInfo {
    
    /// Item title
    var title: String
    
    /// Item content
    var content: String
    
    /// Type of the document info item
    var type: DocumentItemInfoType
    
    /// Prefilled date value
    var prefilledDate: Date?
    
    /// Method return Item content status
    func getStatus() -> DocumentItemInfoStatus {
        
        switch type {
        case .number:
            if !(content.isEmpty) {
                return .valid
            }
        case .expireDate:
            if let date = content.dateFromString() {
                if type == .expireDate {
                    return date.isLaterThanOrEqualTo(Date()) ? .valid : .pastDate
                } else {
                    return .valid
                }
            }
        }
        return .empty
    }
}
