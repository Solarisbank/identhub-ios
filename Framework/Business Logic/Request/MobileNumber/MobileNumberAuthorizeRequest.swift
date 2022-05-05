//
//  AuthorizeRequest.swift
//  IdentHubSDK
//

import Foundation

struct MobileNumberAuthorizeRequest: BackendRequest {

    var path: String {
        "/mobile_number/authorize"
    }

    var method: HTTPMethod {
        .post
    }

}
