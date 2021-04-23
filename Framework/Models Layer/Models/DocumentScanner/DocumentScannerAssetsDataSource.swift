//
//  DocumentScannerAssetsDataSource.swift
//  IdentHubSDK
//

import UIKit
import FourthlineVision

protocol DocumentScannerAssetsDataSource {

    /// Method returns asset for the document scanner item
    /// - Parameter info: info of the document scanner
    func asset(for info: DocumentScannerInfo) -> UIImage
}

extension DocumentScannerAssetsDataSource {

    func asset(for info: DocumentScannerInfo) -> UIImage {
        let mask = maskName(for: info)
        let fileside = filesideName(for: info)
        let suffix = suffixName(for: info)
        let assetName = mask + fileside + suffix + "frame"
        return UIImage(named: assetName, in: Bundle(for: Self.self as! AnyClass), compatibleWith: nil) ?? UIImage()
    }
}

private extension DocumentScannerAssetsDataSource {

    private func maskName(for info: DocumentScannerInfo) -> String {
        switch info.config.type {
        case .passport:
            return "passport_"

        case .idCard:
            return "idcard_"

        default:
            fatalError("Document type is not supported.")
        }
    }

    private func filesideName(for info: DocumentScannerInfo) -> String {
        switch info.step.fileSide {
        case .front:
            return "front_"

        case .back:
            return "back_"

        default:
            fatalError("Side is not supported")
        }
    }

    private func suffixName(for info: DocumentScannerInfo) -> String {
        var suffix = ""
        if info.step.isAngled {
            suffix.append("tilted_")
        }
        switch info.state {
        case .default:
            suffix.append("")
        case .warning:
            suffix.append("warning_")
        case .success:
            suffix.append("success_")
        }
        return suffix
    }
}
