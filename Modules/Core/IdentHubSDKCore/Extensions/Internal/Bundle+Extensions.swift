//
//  Bundle+Extensions.swift
//  IdentHubSDK
//

import Foundation

public extension Bundle {
    static var current: Bundle {
        class BundleClass { }
        return Bundle(for: BundleClass.self)
    }
}
