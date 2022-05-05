//
//  IdentificationInfo.swift
//  IdentHubSDK
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
