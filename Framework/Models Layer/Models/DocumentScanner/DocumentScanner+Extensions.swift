//
//  DocumentScanner+Extensions.swift
//  IdentHubSDK
//

import Foundation
import FourthlineCore
import FourthlineVision

enum DocumentScannerState {

    case `default`
    case warning
    case success
}

struct DocumentScannerInfo {

    let step: DocumentScannerStep
    let config: DocumentScannerConfig
    let state: DocumentScannerState
}

extension DocumentScannerStepWarning {

    var text: String {
        switch self {
        case .deviceNotSteady:
            return Localizable.DocumentScanner.Warning.deviceNotSteady
        case .documentTooDark:
            return Localizable.DocumentScanner.Warning.tooDark
        @unknown default:
            print("Missing DocumentScannerStepWarning.text for \(self)")
            return Localizable.DocumentScanner.Warning.unknown
        }
    }

    var priority: Int {
        switch self {
        case .deviceNotSteady:
            return 0
        case .documentTooDark:
            return 1
        @unknown default:
            print("Missing Value for DocumentScannerStepWarning.priority case \(self)")
            return -1
        }
    }
}

extension DocumentScannerError {

    var text: String {
        switch self {
        case .cameraPermissionNotGranted:
            return Localizable.Camera.premissionNotGranted
        case .scannerInterrupted:
            return Localizable.DocumentScanner.Error.scannerInterrupted
        case .timeout:
            return Localizable.DocumentScanner.Error.timeout
        default:
            return Localizable.Common.defaultErr
        }
    }
}

extension DocumentScannerStep {

    var localizedTitle: String {
        switch fileSide {
        case .front:
            if isAngled {
                return Localizable.DocumentScanner.DocSideTitle.frontAngled
            } else {
                return Localizable.DocumentScanner.DocSideTitle.front
            }
        case .back:
            if isAngled {
                return Localizable.DocumentScanner.DocSideTitle.backAngled
            } else {
                return Localizable.DocumentScanner.DocSideTitle.back
            }
        case .insideLeft:
            if isAngled {
                return Localizable.DocumentScanner.DocSideTitle.insideLeftAngled
            } else {
                return Localizable.DocumentScanner.DocSideTitle.insideLeft
            }
        case .insideRight:
            if isAngled {
                return Localizable.DocumentScanner.DocSideTitle.insideRightAngled
            } else {
                return Localizable.DocumentScanner.DocSideTitle.insideRight
            }
        case .undefined:
            return Localizable.DocumentScanner.DocSideTitle.undefined
        @unknown default:
            print("Missing FileSide.text for \(self)")
            return Localizable.DocumentScanner.DocSideTitle.undefined
        }
    }

    var localizedName: String {
        switch fileSide {
        case .front:
            return Localizable.DocumentScanner.DocSideName.front
        case .back:
            return Localizable.DocumentScanner.DocSideName.back
        case .insideLeft:
            return Localizable.DocumentScanner.DocSideName.insideLeft
        case .insideRight:
            return Localizable.DocumentScanner.DocSideName.insideRight
        case .undefined:
            return Localizable.DocumentScanner.DocSideName.undefined
        @unknown default:
            print("Missing FileSide.text for \(self)")
            return Localizable.DocumentScanner.DocSideName.undefined
        }
    }
}
