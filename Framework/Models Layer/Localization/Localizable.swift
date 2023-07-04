//
//  Localizable.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

enum Localizable {
    typealias Common = IdentHubSDKCore.Localizable.Common
    typealias APIErrorDesc = IdentHubSDKCore.Localizable.APIErrorDesc

    enum StartIdentification {
        static let startIdentification = "start_ident_title".localized()
        static let instructionDisclaimer = "start_ident_disclaimer".localized()
        static let instructionSteps = "start_ident_steps".localized()
        static let followVerificationForNumber = "start_ident_follow_verification".localized()
        static let sendVerificationCode = "start_ident_send_code".localized()
    }

    enum FinishIdentification {
        static let identificationSuccessful = "finish_ident_successful_title".localized()
        static let description = "finish_ident_successful_description".localized()
        static let finish = "finish_ident_successful_action".localized()
    }

}
