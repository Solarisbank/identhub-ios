//
//  Localizable.swift
//  IdentHubSDKBank
//

import IdentHubSDKCore

internal enum Localizable {
    typealias Common = IdentHubSDKCore.Localizable.Common
    typealias APIErrorDesc = IdentHubSDKCore.Localizable.APIErrorDesc
    
    enum BankVerification {
        enum IBANVerification {
            static let title = "identhub_bank_iban_title".localized()
            static let accountDisclaimer = "identhub_bank_iban_description".localized()
            static let IBANEncryptionInfo = "identhub_bank_iban_secured_text".localized()
            static let IBANplaceholder = "iban_verification_iban_input_place_holder".localized()
            static let wrongIBANFormat = "iban_verification_error_iban_format".localized()
            static let failureAlertTitle = "iban_verification_failure_alert_title".localized()
            static let notValidIBAN = "iban_verification_error_invalid_iban".localized()
            static let retryOption = "iban_verification_failure_alert_retry".localized()
            static let alternateOption = "iban_verification_failure_alert_fallback".localized()
        }
        
        enum PaymentVerification {
            static let establishingSecureConnection = "identhub_bank_establishing_connection_text".localized()
            static let processingVerification = "payment_verification_processing".localized()

            enum Success {
                static let title = "identhub_bank_payment_verification_title".localized()
                static let description = "identhub_bank_payment_verification_description".localized()
                static let action = "payment_verification_success_action".localized()
            }

            enum Error {
                static let title = "payment_verification_error_title".localized()
                static let technicalIssueDescription = "payment_verification_error_description".localized()
                static let action = "payment_verification_error_action".localized()
            }
        }
    }
}
