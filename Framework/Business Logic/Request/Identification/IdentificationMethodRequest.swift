//
//  IdentificationMethodRequest.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

final class IdentificationMethodRequest: BackendRequest {
    
    // MARK: - Public attributes -

    var path: String {
        "/"
    }

    var method: HTTPMethod {
        .get
    }
    
}
