//
//  Localizable.swift
//  IdentHubSDKQES
//
import IdentHubSDKCore

internal enum Localizable {
    typealias Common = IdentHubSDKCore.Localizable.Common
    typealias APIErrorDesc = IdentHubSDKCore.Localizable.APIErrorDesc

    enum SignDocuments {
        enum ConfirmApplication {
            static let confirmYourApplication = "sign_documents_application_confirm".localized()
            static let description = "sign_documents_application_description".localized()
            static let docItemTitle = "sign_documents_application_view_doc".localized()
            static let termsAndConditionsFootnote = "sign_documents_application_terms_text".localized()
            static let documentFetchErrorTitle = "sign_document_document_fetch_error_title".localized()
            static let documentFetchErrorMessage = "sign_document_document_fetch_error_message".localized()
        }

        enum Sign {
            static let title = "sign_documents_title".localized()
            static let transactionInfoPartOne = "sign_documents_transaction_info_part_one".localized()
            static let transactionInfoPartTwo = "sign_documents_transaction_info_part_two".localized()
            static let submitAndSign = "sign_documents_submit_and_sign".localized()
            static let requestCode = "sign_documents_request_code".localized()
            static let applicationIsBeingProcessed = "sign_documents_application_being_processed".localized()
            static let downloadDocuments = "sign_documents_download_documents".localized()
        }
    }

    enum PhoneVerification {
        static let enterCode = "phone_verification_enter_code".localized()
        static let requestNewCodeTimer = "phone_verification_request_code_timer".localized()
        static let sendNewCode = "phone_verification_send_new_code".localized()
        static let wrongTan = "phone_verification_wrong_tan".localized()

        enum Error {
            static let title = "phone_verification_error_title".localized()
            static let description = "phone_verification_error_description".localized()
            static let action = "phone_verification_error_action".localized()
            static let requestCodeError = "request_tan_failed".localized()
        }
    }
}
