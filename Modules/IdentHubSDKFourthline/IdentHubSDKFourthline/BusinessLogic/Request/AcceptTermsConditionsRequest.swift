//
//  AcceptTermsConditionsRequest.swift
//  IdentHubSDKFourthline
//
//  Created by Abhijit Soni on 01/06/23.
//

import Foundation
import IdentHubSDKCore

class AcceptTermsConditionsRequest: BackendRequest {
    var path: String {
        "/terms_and_conditions/namirial/accept"
    }
    
    var method: IdentHubSDKCore.HTTPMethod {
        .post
    }
    
    var body: Body? {
        let dictionary = [
            "document_id": documentid,
        ]

        return.json(body: dictionary)
    }

    // MARK: Private properties

    private let documentid: String
    
    // MARK: Initializers


    init(documentid: String) {
        self.documentid = documentid
    }
}
