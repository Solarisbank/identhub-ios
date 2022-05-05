//
//  IPAddressRequest.swift
//  IdentHubSDK
//

import Foundation

final class IPAddressRequest: BackendRequest {

    // MARK: - Public attributes -

    var path: String {
        "/myip"
    }

    var method: HTTPMethod {
        .get
    }

}
