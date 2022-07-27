//
//  MobileNumberRequest.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

struct MobileNumberRequest: BackendRequest, Equatable {

    // MARK: - Public attributes -
    
    var path: String {
        "/mobile_number"
    }

    var method: HTTPMethod {
        .get
    }
   
}
