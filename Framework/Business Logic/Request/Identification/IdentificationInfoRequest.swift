//
//  IdentificationInfo.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

struct IdentificationInfoRequest: BackendRequest {

    var path: String {
        "/info"
    }

    var method: HTTPMethod {
        .get
    }

}
