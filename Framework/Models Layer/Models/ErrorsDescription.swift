//
//  ErrorDescription.swift
//  IdentHubSDK
//

import Foundation

public struct ErrorsDescription: Decodable {

    /// List of request errors
    let errors: [ServerError]?
}
