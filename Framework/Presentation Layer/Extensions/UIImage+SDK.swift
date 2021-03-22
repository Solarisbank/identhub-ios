//
//  UIImage+SDK.swift
//  IdentHubSDK
//

import UIKit

internal extension UIImage {

    /// List of available images.
    enum SDKImage: String {
        case poweredBySolarisbank = "powered_by_solarisbank"
        case establishingSecureConnection = "secure_connection"
        case processingVerification = "processing_verification"
        case documentNotSigned = "document_not_signed"
        case documentSigned = "document_signed"
        case seeDocument = "document_see"
        case info = "info"
        case downloadDocument = "document_download"
        case warning = "warning"
    }

    /// Choose custom available image.
    static func sdkImage(_ image: SDKImage, type: AnyClass) -> UIImage? {
        let bundle = Bundle(for: type)
        let image = UIImage(named: image.rawValue, in: bundle, compatibleWith: nil)
        return image
    }
}
