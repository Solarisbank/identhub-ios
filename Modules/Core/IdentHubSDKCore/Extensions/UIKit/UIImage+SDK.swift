//
//  UIImage+SDK.swift
//  IdentHubSDKCore
//

import UIKit

public extension UIImage {

    /// List of available images.
    enum SDKImage: String {
        case poweredBySolarisbank = "powered_by_solarisbank"
        case establishingSecureConnection = "secure_connection"
        case processingVerification = "processing_verification"
        case documentSigned = "document_signed"
        case downloadDocument = "document_download"
        case warning = "warning"
        case checkmark = "checkmark"
        case viewDocument = "view_document"
    }

    /// Choose custom available image.
    static func sdkImage(_ image: SDKImage, type: AnyClass) -> UIImage? {
        let bundle = Bundle(for: type)
        let image = UIImage(named: image.rawValue, in: bundle, compatibleWith: nil)
        return image
    }
}
