//
//  Array+Extension.swift
//  IdentHubSDK
//

import Foundation

public extension Array {

    /// Method defines if array is not empty, used for more readable code
    /// - Returns: bool value of the emptinest state of array
    func isNotEmpty() -> Bool {
        return ( self.isEmpty == false )
    }
}

public extension Array where Element: Hashable {
    /// Converts array into set removing duplicates.
    /// - Returns: a new set containing all array elements
    func asSet() -> Set<Element> {
        reduce(Set<Element>()) { $0.union([$1]) }
    }
}

public extension Set {
    /// Method defines if array is not empty, used for more readable code
    /// - Returns: bool value of the emptinest state of array
    func isNotEmpty() -> Bool {
        return ( self.isEmpty == false )
    }

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
