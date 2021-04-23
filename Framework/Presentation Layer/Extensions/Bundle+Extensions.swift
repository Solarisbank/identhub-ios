//
//  Bundle+Extensions.swift
//  IdentHubSDK
//

import Foundation

extension Bundle {

    static var current: Bundle {
        class BundleClass { }
        return Bundle(for: BundleClass.self)
    }
}
