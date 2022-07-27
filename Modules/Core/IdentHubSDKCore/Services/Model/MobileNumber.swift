//
//  MobileNumber.swift
//  IdentHubSDK
//

import Foundation

public struct MobileNumber: Decodable, Equatable {

    /// Id.
    public let id: String?

    /// Mobile number of a person.
    public let number: String

    /// Status of mobile number verification.
    public let verified: Bool
}
