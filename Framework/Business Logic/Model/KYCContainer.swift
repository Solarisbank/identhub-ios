//
//  KYCContainer.swift
//  IdentHubSDK
//

import UIKit
import FourthlineKYC
import FourthlineVision
import FourthlineCore

final class KYCContainer {
    static let shared = KYCContainer()
    private init() {}

    let kycInfo: KYCInfo = KYCInfo()

    // MARK: - Filling with Selfie Result Data
    func update(with data: SelfieScannerResult) {
        kycInfo.selfie = SelfieAttachment()
        kycInfo.selfie?.image = data.image.full
        kycInfo.selfie?.location = data.metadata.location
        kycInfo.selfie?.timestamp = data.metadata.timestamp
        kycInfo.selfie?.videoUrl = data.videoUrl
    }
}
