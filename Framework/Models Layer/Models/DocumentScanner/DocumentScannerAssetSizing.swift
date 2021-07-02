//
//  DocumentScannerAssetSizing.swift
//  IdentHubSDK
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

    /// Method returns mask background view color
    /// - Parameter scannerInfo: scanned document info
    func backgroundColorConfiguration(for scannerInfo: DocumentScannerInfo) -> UIColor
}

extension DocumentScannerAssetPlacement {

    func assetConfiguration(for scannerInfo: DocumentScannerInfo) -> DocumentScannerAssetConfiguration {
        typealias Builder = DocumentScannerAssetBuilder

        switch scannerInfo.config.type {
        case .passport:
            return Builder.passport()
        case .idCard,
             .residencePermit:
            return Builder.idCard()
        case .driversLicense,
             .dutchDriversLicense:
            return Builder.driversLicense()
        case .frenchIdCard:
            return Builder.frenchIdCard()
        case .paperId:
            return Builder.paperId(forSide: scannerInfo.step.fileSide)
        default:
            fatalError("Requested asset configuration for \(scannerInfo.config.type) document type. ")
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

    func backgroundColorConfiguration(for scannerInfo: DocumentScannerInfo) -> UIColor {

        switch scannerInfo.config.type {
        case .passport,
             .idCard:
            return .white
        case .paperId:
            return UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        default:
            return UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        }
    }
}
