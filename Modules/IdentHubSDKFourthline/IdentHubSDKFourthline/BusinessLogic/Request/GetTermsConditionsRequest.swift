//
//  GetTermsConditionsRequest.swift
//  IdentHubSDKFourthline
//
//  Created by Abhijit Soni on 01/06/23.
//

import Foundation
import IdentHubSDKCore

class GetTermsConditionsRequest: BackendRequest {
    var path: String {
        "/terms_and_conditions/namirial/latest?language=\(languageCode)"
    }
    
    private let languageCode = CommandLine.locale?.languageCode ?? Locale.preferredLanguageCode
    
    var method: IdentHubSDKCore.HTTPMethod {
        .get
    }
    
}
