//
//  DocumentScannerAssetsDataSource.swift
//  IdentHubSDKFourthline
//

import UIKit
import FourthlineVision

protocol DocumentScannerAssetsDataSource {

    /// Method returns asset for the document scanner item
    /// - Parameter info: info of the document scanner
    /// - Parameter frame: defines if image used for frame border view
    func asset(for info: DocumentScannerInfo, border: Bool) -> UIImage
}

extension DocumentScannerAssetsDataSource {

    func asset(for info: DocumentScannerInfo, border: Bool) -> UIImage {
        let mask = maskName(for: info)
        let fileside = filesideName(for: info)
        let suffix = suffixName(for: info, border: border)
        let assetName = mask + fileside + suffix + "frame"
        return UIImage(named: assetName, in: Bundle(for: Self.self as! AnyClass), compatibleWith: nil) ?? UIImage()
    }
}

private extension DocumentScannerAssetsDataSource {

    private func maskName(for info: DocumentScannerInfo) -> String {
        switch info.config.type {
        case .passport:
            return "passport_"

        case .idCard,
             .tinReferenceDocument,
             .residencePermit:
            return "idcard_"

        case .driversLicense:
            return "driver_license_"

        case .paperId:
            return "paperid_"

        case .frenchIdCard:
            return "frenchid_"

        default:
            print("Document type is not supported.")
            return "unsupported_"
        }
    }

    private func filesideName(for info: DocumentScannerInfo) -> String {
        switch info.step.fileSide {
        case .front:
            return "front_"

        case .back:
            return "back_"

        case .insideLeft:
            return "left_"

        case .insideRight:
            return "right_"

        default:
            print("Side is not supported")
            return "unsupported_"
        }
    }

    private func suffixName(for info: DocumentScannerInfo, border: Bool) -> String {
        var suffix = ""
        if info.step.isAngled {
            suffix.append("tilted_")
        }
        switch info.state {
        case .default:
            suffix.append("")
        case .warning:
            if border {
                suffix.append("warning_")
            }
        case .success:
            if border {
                suffix.append("success_")
            }
        }
        return suffix
    }
}
