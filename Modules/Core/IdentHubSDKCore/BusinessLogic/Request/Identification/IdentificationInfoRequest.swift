//
//  IdentificationInfoRequest.swift
//  IdentHubSDKCore
//

import Foundation

struct IdentificationInfoRequest: BackendRequest {

    var path: String {
        "/info"
    }

    var method: HTTPMethod {
        .get
    }

}
