//
//  NSError+Dummy.swift
//  IdentHubSDKTestBase
//

import Foundation

public extension NSError {
    static let mock = NSError(domain: "solarisbank.de", code: 500)
}
