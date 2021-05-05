//
//  IdentificationMethod.swift
//  IdentHubSDK
//

import Foundation

struct IdentificationMethod: Decodable {

    /// ID Now identification type is enabled
    let idnowIdentification: Bool

    /// Fourthline identification type is enabled
    let fourthlineIdentification: Bool

    /// BankID identificaiton is enabled
    let bankIdentificaiton: Bool

    enum CodingKeys: String, CodingKey {
        case idnowIdentification = "idnow"
        case fourthlineIdentification = "fourthline"
        case bankIdentificaiton = "bank"
    }
}
