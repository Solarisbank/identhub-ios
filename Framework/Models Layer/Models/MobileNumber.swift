//
//  MobileNumber.swift
//  IdentHubSDK
//

import Foundation

struct MobileNumber: Decodable {

    /// Id.
    let id: String

    /// Mobile number of a person.
    let number: String

    /// Status of mobile number verification.
    let verified: Bool
}
