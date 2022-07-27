//
//  AuthorizeRequest.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

struct MobileNumberAuthorizeRequest: BackendRequest {

    var path: String {
        "/mobile_number/authorize"
    }

    var method: HTTPMethod {
        .post
    }

}
