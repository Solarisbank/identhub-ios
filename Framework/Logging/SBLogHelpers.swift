//
//  SBLogHelpers.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

extension Error {
    var logDescription: String {
        switch self {
        case let error as ResponseError:
            return error.description
        default:
            return String(describing: self)
        }
    }
}

extension Result {
    /// Provide a text representation of the result suitable for logging.
    var logDescription: String {
        switch self {
        case .failure(let error):
            return error.logDescription
        case .success(let success):
            return String(describing: type(of: success))
        }
    }
}
