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

extension FileSide {

    var text: String {
        switch self {
        case .front:
            return Localizable.DocumentScanner.DocFileSide.front
        case .back:
            return Localizable.DocumentScanner.DocFileSide.back
        case .insideLeft:
            return Localizable.DocumentScanner.DocFileSide.insideLeft
        case .insideRight:
            return Localizable.DocumentScanner.DocFileSide.insideRight
        case .undefined:
            print("undefined should never happen")
            return Localizable.DocumentScanner.DocFileSide.undefined
        @unknown default:
            print("Missing FileSide.text for \(self)")
            return Localizable.DocumentScanner.DocFileSide.undefined
        }
    }
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

    var name: String {
        let filesideNameAngled = "\(fileSide.text) angled".capitalized
        return isAngled ? filesideNameAngled : fileSide.text.capitalized
    }
}
