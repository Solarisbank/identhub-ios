//
//  MobileNumberRequest.swift
//  IdentHubSDK
//

import Foundation

struct MobileNumberRequest: BackendRequest {

    // MARK: - Public attributes -
    
    var path: String {
        "/mobile_number"
    }

    var method: HTTPMethod {
        .get
    }
   
}
