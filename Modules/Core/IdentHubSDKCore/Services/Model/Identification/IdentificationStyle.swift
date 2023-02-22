//
//  IdentificationStyle.swift
//  IdentHubSDKCore
//

import Foundation

public struct IdentificationStyle: Decodable {

    /// Set of colors used in app
    public let colors: StyleColors?

    /// Action button corner radius value in pixels
    public let buttonBorderRadius: String?

    /// Enter fields border radius value in pixels
    public let inputBorderRadius: String?

    /// Enter data field border width in pixels
    public let inputBorderWidth: String?

    /// Set of the font family used in SDK
    public let fontFamily: [String]?

    /// Company logo used in SDK
    public let logo: String?
}
