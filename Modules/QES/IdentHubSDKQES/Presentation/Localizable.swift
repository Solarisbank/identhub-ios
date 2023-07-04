//
//  Localizable.swift
//  IdentHubSDKQES
//
import IdentHubSDKCore

internal enum Localizable {
    typealias Common = IdentHubSDKCore.Localizable.Common
    typealias APIErrorDesc = IdentHubSDKCore.Localizable.APIErrorDesc
    typealias PhoneVerification = IdentHubSDKCore.Localizable.PhoneVerification

    enum SignDocuments {
        enum ConfirmApplication {
            static let confirmYourApplication = "identhub_qes_doc_title".localized()
            static let description = "identhub_qes_doc_description".localized()
            static let docItemTitle = "sign_documents_application_view_doc".localized()
            static let termsAndConditionsFootnote = "identhub_qes_doc_terms_and_conditions_text".localized()
            static let documentFetchErrorTitle = "sign_document_document_fetch_error_title".localized()
            static let documentFetchErrorMessage = "sign_document_document_fetch_error_message".localized()
        }

        enum Sign {
            static let title = "identhub_phone_verification_qes_title".localized()
            static let transactionDetailText = "identhub_phone_transcation_detail_text".localized()
            static let submitAndSign = "sign_documents_submit_and_sign".localized()
            static let requestCode = "sign_documents_request_code".localized()
            static let applicationIsBeingProcessed = "sign_documents_application_being_processed".localized()
            static let downloadDocuments = "sign_documents_download_documents".localized()
        }
    }
    
}
