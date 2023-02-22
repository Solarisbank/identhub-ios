//
//  IPAddressRequest.swift
//  IdentHubSDKFourthline
//

import Foundation
import IdentHubSDKCore

final class IPAddressRequest: BackendRequest {

    // MARK: - Public attributes -

    var path: String {
        "/myip"
    }

    var method: HTTPMethod {
        .get
    }

}

