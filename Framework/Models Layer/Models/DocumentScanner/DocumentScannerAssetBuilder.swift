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

        let layout = DocumentScannerAssetLayout(screenWidthRatio: 0.88, screenCenterYMultiplier: 0.85)

        return DocumentScannerAssetConfiguration(sizing: sizing, tiltedSizing: sizing, layout: layout)
    }

    static func driversLicense() -> DocumentScannerAssetConfiguration {
        let sizing = DocumentScannerAssetSizing(aspectRatio: 0.608, detectionAreaOriginRatio: .zero, detectionAreaSizeRatio: CGSize(width: 1.0, height: 1.0))

        let layout = DocumentScannerAssetLayout(screenWidthRatio: 0.95, screenCenterYMultiplier: 0.85)
        return DocumentScannerAssetConfiguration(sizing: sizing, tiltedSizing: sizing, layout: layout)
    }

    static func frenchIdCard() -> DocumentScannerAssetConfiguration {
        let sizing = DocumentScannerAssetSizing(aspectRatio: 0.7092, detectionAreaOriginRatio: CGPoint(x: 0.025, y: 0), detectionAreaSizeRatio: CGSize(width: 0.95, height: 1.0))

        let layout = DocumentScannerAssetLayout(screenWidthRatio: 0.95, screenCenterYMultiplier: 0.85)
        return DocumentScannerAssetConfiguration(sizing: sizing, tiltedSizing: sizing, layout: layout)
    }

    static func paperId(forSide fileSide: FileSide) -> DocumentScannerAssetConfiguration {
        if fileSide == .insideLeft {
            return paperIdLeft()
        } else if fileSide == .insideRight {
            return paperIdRight()
        } else {
            return paperIdBack()
        }
    }
}

// MARK: - Private PaperID
private extension DocumentScannerAssetBuilder {

    static func paperIdBack() -> DocumentScannerAssetConfiguration {
        let sizing = DocumentScannerAssetSizing(aspectRatio: 1.232, detectionAreaOriginRatio: CGPoint(x: 0.0773, y: 0.0368), detectionAreaSizeRatio: CGSize(width: 0.8426, height: 0.9242))

        let layout = DocumentScannerAssetLayout(screenWidthRatio: 0.955, screenCenterYMultiplier: 0.85)
        return DocumentScannerAssetConfiguration(sizing: sizing, tiltedSizing: sizing, layout: layout)
    }

    static func paperIdLeft() -> DocumentScannerAssetConfiguration {
        let sizing = DocumentScannerAssetSizing(aspectRatio: 1.232, detectionAreaOriginRatio: CGPoint(x: 0, y: 0.0714), detectionAreaSizeRatio: CGSize(width: 0.84, height: 0.921))

        let tilted = DocumentScannerAssetSizing(aspectRatio: 1.232, detectionAreaOriginRatio: CGPoint(x: 0, y: 0.04), detectionAreaSizeRatio: CGSize(width: 0.7853, height: 0.9188))

        let layout = DocumentScannerAssetLayout(screenWidthRatio: 0.955, screenCenterYMultiplier: 0.85)
        return DocumentScannerAssetConfiguration(sizing: sizing, tiltedSizing: tilted, layout: layout)
    }

    static func paperIdRight() -> DocumentScannerAssetConfiguration {
        let sizing = DocumentScannerAssetSizing(aspectRatio: 1.232, detectionAreaOriginRatio: CGPoint(x: 0.1613, y: 0.0714), detectionAreaSizeRatio: CGSize(width: 0.84, height: 0.921))

        let tilted = DocumentScannerAssetSizing(aspectRatio: 1.232, detectionAreaOriginRatio: CGPoint(x: 0.2146, y: 0.04), detectionAreaSizeRatio: CGSize(width: 0.7853, height: 0.9188))

        let layout = DocumentScannerAssetLayout(screenWidthRatio: 0.955, screenCenterYMultiplier: 0.85)
        return DocumentScannerAssetConfiguration(sizing: sizing, tiltedSizing: tilted, layout: layout)
    }
}
