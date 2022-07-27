//
//  Bundle+Extensions.swift
//  IdentHubSDK
//

import Foundation

internal extension Bundle {
    static var current: Bundle {
        class BundleClass { }
        return Bundle(for: BundleClass.self)
    }
}
