//
//  Bundle+Extensions.swift
//  Fourthline
//

import Foundation

internal extension Bundle {
    static var current: Bundle {
        class BundleClass { }
        return Bundle(for: BundleClass.self)
    }
}
