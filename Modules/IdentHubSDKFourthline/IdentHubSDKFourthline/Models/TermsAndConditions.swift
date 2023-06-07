//
//  TermsAndConditions.swift
//  IdentHubSDKCore
//

import Foundation
struct TermsAndConditions: Codable, Equatable {

   /// Terms and conditions pdf url
    var url: String

    /// Terms and conditions document id
    var documentid: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url"
        case documentid = "document_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.url = try container.decode(String.self, forKey: .url)
        self.documentid = try container.decode(String.self, forKey: .documentid)
    }
}
