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
        public static let kycZipMissing = "Kyc.zip file is missing"
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
        static let waiting = "identhub_generic_please_wait_title".localized()
    }

    enum Quiting {
        static let title = "quitting_title".localized()
        static let description = "quitting_description".localized()
        static let stay = "quitting_stay_action".localized()
    }
    
    enum TermsConditions {
        static let description = "identhub_startup_terms_and_conditions_info".localized()
        static let privacyText = "terms_privacy_text".localized()
        static let termsText = "identhub_startup_terms_and_conditions_title".localized()
        static let agreementLinks = "identhub_startup_terms_and_conditions_checkbox_text".localized()
        static let continueBtn = "terms_continue_button".localized()
    }
    
    public enum PhoneVerification {
        public static let title = "identhub_phone_verification_title".localized()
        public static let enterCode = "identhub_phone_verification_description".localized()
        public static let requestNewCodeTimer = "identhub_phone_verification_request_code".localized()
        public static let sendNewCode = "identhub_phone_verification_send_new_code".localized()
        public static let wrongTan = "phone_verification_wrong_tan".localized()
        public static let submitCode = "phone_verification_submit_code".localized()
        public static let requestNewCode = "phone_verification_request_new_code".localized()

        public enum Success {
            public static let title = "identhub_phone_verification_success_title".localized()
            public static let description = "identhub_phone_verification_success_description".localized()
            public static let loginCredentials = "phone_verification_login_credentials".localized()
        }
        
        public enum Error {
            public static let title = "phone_verification_error_title".localized()
            public static let description = "phone_verification_error_description".localized()
            public static let action = "phone_verification_error_action".localized()
            public static let requestCodeError = "request_tan_failed".localized()
        }
    }
    
    enum Initial {
        static let title = "initial_title".localized()
        static let description = ""
        static let define = "initial_define".localized()
        static let info = "initial_info".localized()
        static let register = "initial_register".localized()
        static let prefetch = "initial_prefetch".localized()
    }
    
    public enum FetchData {
        public static let title = "fetch_data_title".localized()
        public static let description = ""
        public static let person = "fetch_data_person".localized()
        public static let location = "fetch_data_location".localized()
        public static let ipAddress = "fetch_data_ip_address".localized()
    }
     
    public enum Location {
        public static let title = "location_title".localized()
        public static let description = "location_description".localized()

        public enum Error {
            public static let title = "location_error_title".localized()
            public static let message = "location_error_message".localized()
        }
    }
    
    public enum Zipper {
        public enum Error {
            public static let kycIsNotValid = "zipper_error_kyc_invalid".localized()
            public static let zipFoundationNotImported = "zipper_error_zip_foundation_not_imported".localized()
            public static let zipExceedMaximumSize = "zipper_error_zip_exceed_max_size".localized()
            public static let cannotCreateZip = "zipper_error_cannot_create_zip".localized()
            public static let notEnoughSpace = "zipper_error_not_enough_space".localized()
            public static let unknown = "zipper_error_unknown".localized()
            public static let alertTitle = "zipper_error_alert_title".localized()
        }
    }
    
    public enum Verification {
        public static let title = "identhub_fourthline_kyc_upload_title".localized()
        public static let description = "verification_description".localized()
        public static let processTitle = "verification_process_title".localized()
    }
    
}
