//
//  MobileNumberAuthorizeRequest.swift
//  IdentHubSDKCore
//

import Foundation

internal struct MobileNumberAuthorizeRequest: BackendRequest, Equatable {

    var path: String {
        "/mobile_number/authorize"
    }

    var method: HTTPMethod {
        .post
    }

}
