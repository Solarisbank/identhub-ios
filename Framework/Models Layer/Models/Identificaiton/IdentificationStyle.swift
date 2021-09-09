//
//  IdentificationStyle.swift
//  IdentHubSDK
//

import Foundation

struct IdentificationStyle: Decodable {

    /// Set of colors used in app
    let colors: StyleColors?

    /// Action button corner radius value in pixels
    let buttonBorderRadius: String?

    /// Enter fields border radius value in pixels
    let inputBorderRadius: String?

    /// Enter data field border width in pixels
    let inputBorderWidth: String?

    /// Set of the font family used in SDK
    let fontFamily: [String]?

    /// Company logo used in SDK
    let logo: String?
}
