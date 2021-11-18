//
//  SelfieScanner+Extensions.swift
//  IdentHubSDK
//

import FourthlineVision

extension SelfieScannerWarning {

    var priority: Int {
        switch self {
        case .deviceNotSteady:
            return 0
        case .faceYawTooBig:
            return 1
        case .faceTooFar:
            return 2
        case .faceTooClose:
            return 3
        case .faceNotInFrame:
            return 4
        case .faceNotDetected:
            return 5
        @unknown default:
            print("Missing SelfieScannerWarning.priority for \(self)")
            return -1
        }
    }

    var text: String {
        switch self {
        case .faceNotInFrame:
            return Localizable.Selfie.Warnings.faceNotInFrame
        case .faceNotDetected:
            return Localizable.Selfie.Warnings.faceNotDetected
        case .faceTooClose:
            return Localizable.Selfie.Warnings.faceTooClose
        case .faceTooFar:
            return Localizable.Selfie.Warnings.faceTooFar
        case .faceYawTooBig:
            return Localizable.Selfie.Warnings.faceYawTooBig
        case .deviceNotSteady:
            return Localizable.Selfie.Warnings.deviceNotSteady
        @unknown default:
            print("Missing SelfieScannerWarning.text for \(self)")
            return Localizable.Selfie.Warnings.unknown
        }
    }
}

extension SelfieScannerStep {

    var text: String {
        switch self {
        case .turnHeadLeft:
            return Localizable.Selfie.Liveness.turnHeadLeft
        case .turnHeadRight:
            return Localizable.Selfie.Liveness.turnHeadRight
        default:
            return ""
        }
    }
}

extension SelfieScannerError {

    var text: String {
        switch self {
        case .timeout:
            return Localizable.Selfie.Errors.timeout
        case .faceDisappeared:
            return Localizable.Selfie.Errors.faceDisappeared
        case .cameraPermissionNotGranted:
            return Localizable.Selfie.Errors.cameraPermissionNotGranted
        case .manualSelfieNotAllowed:
            return Localizable.Selfie.Errors.manualSelfieNotAllowed
        case .recordingFailed:
            return Localizable.Selfie.Errors.recordingFailed
        case .recordAudioPermissionNotGranted:
            return Localizable.Selfie.Errors.unknown
        case .scannerInterrupted:
            return Localizable.Selfie.Errors.scannerInterrupted
        case .multipleFacesDetected:
            return Localizable.Selfie.Errors.multipleFaces
        case .resetScannerNotAllowed:
            return Localizable.Selfie.Errors.resetScannerNotAllowed
        case .unknown:
            return Localizable.Selfie.Errors.unknown
        @unknown default:
            print("Missing SelfieScannerError.text for \(self)")
            return Localizable.Selfie.Errors.unknown
        }
    }
}
