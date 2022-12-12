//
//  Localizable.swift
//  IdentHubSDKCore
//

public enum Localizable {
    public enum APIErrorDesc {
        public static let malformedResponseJson = "api_error_malformed_json".localized()
        public static let clientError = "api_error_client_error".localized()
        public static let authorizationFailed = "api_error_authorization_failed".localized()
        public static let unauthorizedAction = "api_error_unauthorized".localized()
        public static let expectationMismatch = "api_error_data_mismatch".localized()
        public static let incorrectIdentificationStatus = "api_error_incorrect_ident_status".localized()
        public static let unprocessableEntity = "api_error_unprocessable_entity".localized()
        public static let internalServerError = "api_error_internal_server_error".localized()
        public static let requestError = "api_error_request_build_error".localized()
        public static let unknownError = "api_error_unknown".localized()
        public static let resourceNotFound = "api_error_resource_not_found".localized()
        public static let locationAccessError = "api_error_location_permission".localized()
        public static let locationError = "api_error_location_error".localized()
        public static let ibanVerificationError = "api_error_iban_verification".localized()
        public static let paymentFailure = "api_error_payment_failure".localized()
        public static let modulesNotFound = "api_error_modules_not_found".localized()
        public static let unsupportedResponse = "SDK encountered a response that is not supported in this version"
        public static let identificationNotPossible = "SDK could not identify the user. Try your fallback identification method."
    }

    public enum Common {
        public static let next = "common_next".localized()
        public static let quit = "common_quit".localized()
        public static let continueBtn = "common_continue_button".localized()
        public static let back = "common_back".localized()
        public static let poweredBySolarisBank = "common_powered_by_solarisbank".localized()
        public static let verifying = "common_verifying".localized()
        public static let downloadAllDocuments = "common_download_all_documents".localized()
        public static let dismiss = "common_dismiss".localized()
        public static let tryAgain = "common_try_again".localized()
        public static let cancel = "common_cancel".localized()
        public static let settings = "common_settings".localized()
        public static let defaultErr = "common_generic_error".localized()
        public static let confirm = "common_confirm".localized()
        public static let wrongTan = "phone_verification_wrong_tan".localized()
        public static let IBAN = "iban_verification_iban".localized()
    }
    
    enum IdentificationProgressView {
        static let identificationProgress = "progress_view_progress".localized()
        static let phoneVerification = "progress_view_phone_verification".localized()
        static let bankVerification = "progress_view_bank_verification".localized()
        static let documents = "progress_view_sign_documents".localized()
    }

    enum Quiting {
        static let title = "quitting_title".localized()
        static let description = "quitting_description".localized()
        static let stay = "quitting_stay_action".localized()
    }
    
    enum PhoneVerification {
        static let title = "phone_verification_title".localized()
        static let enterCode = "phone_verification_enter_code".localized()
        static let requestNewCodeTimer = "phone_verification_request_code_timer".localized()
        static let sendNewCode = "phone_verification_send_new_code".localized()
        static let wrongTan = "phone_verification_wrong_tan".localized()
        static let submitCode = "phone_verification_submit_code".localized()
        static let requestNewCode = "phone_verification_request_new_code".localized()

        enum Success {
            static let title = "phone_verification_success_title".localized()
            static let description = "phone_verification_success_description".localized()
            static let loginCredentials = "phone_verification_login_credentials".localized()
        }
        
        enum Error {
            static let title = "phone_verification_error_title".localized()
            static let description = "phone_verification_error_description".localized()
            static let action = "phone_verification_error_action".localized()
            static let requestCodeError = "request_tan_failed".localized()
        }
    }
}
