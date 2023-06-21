//
//  DocumentScannerAssetSizing.swift
//  IdentHubSDKFourthline
//

import UIKit

protocol DocumentScannerAssetPlacement {

    /// Method builds document frame asset configuration: size, mask image, position, detection area, etc
    /// - Parameter scannerInfo: scanned document info
    func assetConfiguration(for scannerInfo: DocumentScannerInfo) -> DocumentScannerAssetConfiguration

    /// Method calculates detection scanner area
    /// - Parameters:
    ///   - frame: document scanner frame image view frame
    ///   - sizing: document frame image size
    func detectionArea(inside frame: CGRect, from sizing: DocumentScannerAssetSizing) -> CGRect
}

extension DocumentScannerAssetPlacement {

    func assetConfiguration(for scannerInfo: DocumentScannerInfo) -> DocumentScannerAssetConfiguration {
        typealias Builder = DocumentScannerAssetBuilder

        switch scannerInfo.config.type {
        case .passport:
            return Builder.passport()
        case .idCard,
             .tinReferenceDocument,
             .residencePermit:
            return Builder.idCard()
        case .driversLicense:
            return Builder.driversLicense()
        case .frenchIdCard:
            return Builder.frenchIdCard()
        case .paperId:
            return Builder.paperId(forSide: scannerInfo.step.fileSide)
        default:
            print("Requested asset configuration for \(scannerInfo.config.type) document type. ")
            return Builder.idCard()
        }
    }

    func detectionArea(inside frame: CGRect, from sizing: DocumentScannerAssetSizing) -> CGRect {
        var area = CGRect.zero

        area.origin.x = frame.origin.x + frame.width * sizing.detectionAreaOriginRatio.x
        area.origin.y = frame.origin.y + frame.height * sizing.detectionAreaOriginRatio.y
        area.size.width = frame.size.width * sizing.detectionAreaSizeRatio.width
        area.size.height = frame.size.height * sizing.detectionAreaSizeRatio.height

        return area
    }
}

