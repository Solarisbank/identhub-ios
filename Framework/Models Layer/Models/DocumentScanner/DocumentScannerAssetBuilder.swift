//
//  DocumentScannerAssetBuilder.swift
//  IdentHubSDK
//

import UIKit
import FourthlineCore

struct DocumentScannerAssetConfiguration {
    let sizing: DocumentScannerAssetSizing
    let tiltedSizing: DocumentScannerAssetSizing
    let layout: DocumentScannerAssetLayout
}

struct DocumentScannerAssetSizing {
    let aspectRatio: CGFloat
    let detectionAreaOriginRatio: CGPoint
    let detectionAreaSizeRatio: CGSize
}

struct DocumentScannerAssetLayout {
    let screenWidthRatio: CGFloat
    let screenCenterYMultiplier: CGFloat
}

enum DocumentScannerAssetBuilder {

    static func passport() -> DocumentScannerAssetConfiguration {
        let sizing = DocumentScannerAssetSizing(aspectRatio: 0.857, detectionAreaOriginRatio: CGPoint(x: 0.03, y: 0.18), detectionAreaSizeRatio: CGSize(width: 0.93, height: 0.72))

        let tilted = DocumentScannerAssetSizing(aspectRatio: 0.857, detectionAreaOriginRatio: CGPoint(x: 0.034, y: 0.18), detectionAreaSizeRatio: CGSize(width: 0.92, height: 0.72))

        let layout = DocumentScannerAssetLayout(screenWidthRatio: 0.95, screenCenterYMultiplier: 0.9)
        return DocumentScannerAssetConfiguration(sizing: sizing, tiltedSizing: tilted, layout: layout)
    }

    static func idCard() -> DocumentScannerAssetConfiguration {
        let sizing = DocumentScannerAssetSizing(aspectRatio: 0.668, detectionAreaOriginRatio: CGPoint(x: 0.025, y: 0), detectionAreaSizeRatio: CGSize(width: 0.95, height: 1.0))

        let layout = DocumentScannerAssetLayout(screenWidthRatio: 0.88, screenCenterYMultiplier: 0.75)

        return DocumentScannerAssetConfiguration(sizing: sizing, tiltedSizing: sizing, layout: layout)
    }
}
