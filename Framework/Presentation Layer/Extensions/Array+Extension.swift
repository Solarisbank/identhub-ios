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
