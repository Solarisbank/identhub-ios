//
//  Array+Extension.swift
//  IdentHubSDK
//

import Foundation

extension Array {

    /// Method defines if array is not empty, used for more readable code
    /// - Returns: bool value of the emptinest state of array
    func isNotEmpty() -> Bool {
        return ( self.isEmpty == false )
    }
}

extension Set {

    /// Map, but for a `Set`.
    /// - Parameter transform: The transform to apply to each element.
    func map<T>(_ transform: (Element) throws -> T) rethrows -> Set<T> {
        var tempSet = Set<T>()

        try forEach {
            tempSet.insert(try transform($0))
        }

        return tempSet
    }
}
