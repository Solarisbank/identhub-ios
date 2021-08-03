//
//  IPAddress.swift
//  IdentHubSDK
//

import Foundation

struct IPAddress: Decodable {

    /// Device requested IP-address value
    let ip: String

    enum CodingKeys: String, CodingKey {
        case ip
    }
}
