//
//  Localizable.swift
//  IdentHubSDK
//

import Foundation

enum Localizable {
    enum IdentificationProgressView {
        static let identificationProgress = "progress_view_progress".localized()
        static let phoneVerification = "progress_view_phone_verification".localized()
        static let bankVerification = "progress_view_bank_verification".localized()
        static let documents = "progress_view_sign_documents".localized()
    }

    enum Common {
        static let next = "common_next".localized()
        static let quit = "common_quit".localized()
        static let continueBtn = "common_continue_button".localized()
        static let back = "common_back".localized()
        static let poweredBySolarisBank = "common_powered_by_solarisbank".localized()
        static let verifying = "common_verifying".localized()
        static let downloadAllDocuments = "common_download_all_documents".localized()
        static let dismiss = "common_dismiss".localized()
        static let tryAgain = "common_try_again".localized()
        static let cancel = "common_cancel".localized()
        static let settings = "common_settings".localized()
        static let defaultErr = "common_generic_error".localized()
        static let confirm = "common_confirm".localized()
    }

    enum Quiting {
        static let title = "quitting_title".localized()
        static let description = "quitting_description".localized()
        static let stay = "quitting_stay_action".localized()
    }

    enum StartIdentification {
        static let startIdentification = "start_ident_title".localized()
        static let instructionDisclaimer = "start_ident_disclaimer".localized()
        static let instructionSteps = "start_ident_steps".localized()
        static let followVerificationForNumber = "start_ident_follow_verification".localized()
        static let sendVerificationCode = "start_ident_send_code".localized()
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

    enum BankVerification {
        enum IBANVerification {
            static let title = "iban_verification_title".localized()
            static let accountDisclaimer = "iban_verification_account_disclaimer".localized()
            static let IBAN = "iban_verification_iban".localized()
            static let IBANEncryptionInfo = "iban_verification_iban_encryption".localized()
            static let IBANplaceholder = "iban_verification_iban_input_place_holder".localized()
            static let wrongIBANFormat = "iban_verification_error_iban_format".localized()
            static let failureAlertTitle = "iban_verification_failure_alert_title".localized()
            static let notValidIBAN = "iban_verification_error_invalid_iban".localized()
            static let retryOption = "iban_verification_failure_alert_retry".localized()
            static let alternateOption = "iban_verification_failure_alert_fallback".localized()
        }

        enum PaymentVerification {
            static let establishingSecureConnection = "payment_verification_establishing_connection".localized()
            static let processingVerification = "payment_verification_processing".localized()

            enum Success {
                static let title = "payment_verification_success_title".localized()
                static let description = "payment_verification_success_description".localized()
                static let action = "payment_verification_success_action".localized()
            }

            enum Error {
                static let title = "payment_verification_error_title".localized()
                static let technicalIssueDescription = "payment_verification_error_description".localized()
                static let action = "payment_verification_error_action".localized()
            }
        }
    }

    enum SignDocuments {
        enum ConfirmApplication {
            static let confirmYourApplication = "sign_documents_application_confirm".localized()
            static let description = "sign_documents_application_description".localized()
            static let docItemTitle = "sign_documents_application_view_doc".localized()
            static let termsAndConditionsFootnote = "sign_documents_application_terms_text".localized()
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

    enum FinishIdentification {
        static let identificationSuccessful = "finish_ident_successful_title".localized()
        static let description = "finish_ident_successful_description".localized()
        static let finish = "finish_ident_successful_action".localized()
    }

    enum Initial {
        static let title = "initial_title".localized()
        static let description = ""
        static let define = "initial_define".localized()
        static let info = "initial_info".localized()
        static let register = "initial_register".localized()
        static let prefetch = "initial_prefetch".localized()
    }

    enum FetchData {
        static let title = "fetch_data_title".localized()
        static let description = ""
        static let person = "fetch_data_person".localized()
        static let location = "fetch_data_location".localized()
        static let ipAddress = "fetch_data_ip_address".localized()
    }

    enum TermsConditions {
        static let description = "terms_description".localized()
        static let privacyText = "terms_privacy_text".localized()
        static let termsText = "terms_terms_text".localized()
        static let agreementLinks = "terms_agreement_links".localized()
        static let continueBtn = "terms_continue_button".localized()
    }

    enum Welcome {
        static let pageTitle = "welcome_page_title".localized()
        static let startBtn = "welcome_start_button".localized()

        static let cameraTitle = "welcome_camera_title".localized()
        static let cameraDesc = "welcome_camera_description".localized()

        static let documentTitle = "welcome_document_title".localized()
        static let documentDesc = "welcome_document_description".localized()

        static let locationTitle = "welcome_location_title".localized()
        static let locationDesc = "welcome_location_description".localized()
        
        static let acknowledgement = "welcome_page_acknowledgement".localized()
        static let fourthlinePrivacy = "welcome_page_fourthline_privacy".localized()
    }

    enum Selfie {
        static let selfieTitle = "selfie_title".localized()
        static let scanning = "selfie_scanning".localized()
        static let detected = "selfie_detected".localized()
        static let success = "selfie_success".localized()
        static let retake = "selfie_retake".localized()
        static let confirm = "selfie_confirm".localized()
        static let confirmSelfie = "selfie_confirm_selfie".localized()

        enum Warnings {
            static let faceNotInFrame = "selfie_warning_face_not_in_frame".localized()
            static let faceNotDetected = "selfie_warning_face_not_detected".localized()
            static let faceTooClose = "selfie_warning_face_too_close".localized()
            static let faceTooFar = "selfie_warning_face_too_far".localized()
            static let faceYawTooBig = "selfie_warning_face_camera_directly".localized()
            static let multipleFacesDetected = "selfie_warning_multiple_faces_detected".localized()
            static let deviceNotSteady = "selfie_warning_device_not_steady".localized()
            static let noFace = "selfie_warning_looking_for_face".localized()
            static let unknown = "selfie_warning_unknown".localized()
        }

        enum Errors {
            static let failed = "selfie_error_failed".localized()
            static let timeout = "selfie_error_timeout".localized()
            static let faceDisappeared = "selfie_error_face_disappeared".localized()
            static let cameraPermissionNotGranted = "selfie_error_camer_permission".localized()
            static let recordingFailed = "selfie_error_recording_failed".localized()
            static let scannerInterrupted = "selfie_error_scanner_interrupted".localized()
            static let multipleFaces = "selfie_error_multiple_faces".localized()
            static let resetScannerNotAllowed = "selfie_error_reset_not_allowed".localized()
            static let unknown = "selfie_error_unknown".localized()
            static let alertTitle = "selfie_error_alert_title".localized()
            static let alertMessage = "selfie_error_alert_message".localized()
        }

        enum Liveness {
            static let title = "selfie_liveness_title".localized()
            static let checking = "selfie_liveness_checking".localized()
            static let confirm = "selfie_liveness_confirm".localized()
            static let failed = "selfie_liveness_faild".localized()
            static let turnHeadLeft = "selfie_liveness_turn_head_left".localized()
            static let turnHeadRight = "selfie_liveness_turn_head_right".localized()
        }
    }

    enum Camera {
        static let permissionErrorAlertTitle = "camera_permission_error_title".localized()
        static let permissionErrorAlertMessage = "camera_permission_error_message".localized()
        static let errorMessage = "camera_error_message".localized()
        static let premissionNotGranted = "camera_permission_not_granted".localized()
    }

    enum DocumentScanner {

        static let title = "doc_scanner_title".localized()
        static let description = "doc_scanner_description".localized()
        static let passport = "doc_scanner_passport".localized()
        static let idCard = "doc_scanner_id_card".localized()
        static let paperID = "doc_scanner_paper_id".localized()
        static let successScan = "doc_scanner_scan_successful".localized()
        static let scanning = "doc_scanner_scanning".localized()
        static let scanFailed = "doc_scanner_scan_failed".localized()
        static let retake = "doc_scanner_retake".localized()
        static let confirmResult = "doc_scanner_confirm_result".localized()

        enum DocSideName {
            static let front = "doc_scanner_side_front_name".localized()
            static let back = "doc_scanner_side_back_name".localized()
            static let insideLeft = "doc_scanner_side_inside_left_name".localized()
            static let insideRight = "doc_scanner_side_inside_right_name".localized()
            static let undefined = "doc_scanner_side_undefined_name".localized()
        }

        enum DocSideTitle {
            static let front = "doc_scanner_side_front_title".localized()
            static let frontAngled = "doc_scanner_side_front_angled_title".localized()
            static let back = "doc_scanner_side_back_title".localized()
            static let backAngled = "doc_scanner_side_back_angled_title".localized()
            static let insideLeft = "doc_scanner_side_inside_left_title".localized()
            static let insideLeftAngled = "doc_scanner_side_inside_left_angled_title".localized()
            static let insideRight = "doc_scanner_side_inside_right_title".localized()
            static let insideRightAngled = "doc_scanner_side_inside_right_angled_title".localized()
            static let undefined = "doc_scanner_side_undefined_title".localized()
        }

        enum Warning {
            static let deviceNotSteady = "doc_scanner_warning_device_not_steady".localized()
            static let tooDark = "doc_scanner_warning_too_dark".localized()
            static let unknown = "doc_scanner_warning_unkown".localized()
        }

        enum Error {
            static let scannerInterrupted = "doc_scanner_error_interrupted".localized()
            static let timeout = "doc_scanner_error_timeout".localized()
            static let alertTitle = "doc_scanner_error_alert_title".localized()
            static let alertMessage = "doc_scanner_error_alert_message".localized()
            static let takeSnapshotNotAllowed = "doc_scanner_error_snapshot_not_allowed".localized()
            static let moveToNextStepNotAllowed = "doc_scanner_error_step_not_finished".localized()
            static let resetCurrentStepNotAllowed = "doc_scanner_error_reset_not_allowed".localized()
        }

        enum Information {
            static let title = "doc_scanner_info_title".localized()
            static let docNumber = "doc_scanner_info_doc_number".localized()
            static let issue = "doc_scanner_info_issue_date".localized()
            static let expire = "doc_scanner_info_expire_date".localized()
            static let warning = "doc_scanner_info_warning".localized()
            static let enterData = "doc_scanner_info_enter_data".localized()
            static let confirmData = "doc_scanner_info_confirm_data".localized()
            static let expireDateMessage = "doc_scanner_info_expire_date_message".localized()
        }
    }

    enum Location {
        static let title = "location_title".localized()
        static let description = "location_description".localized()

        enum Error {
            static let title = "location_error_title".localized()
            static let message = "location_error_message".localized()
        }
    }

    enum Upload {
        static let title = "upload_data_title".localized()
        static let description = "upload_data_description".localized()
        static let uploading = "upload_data_uploading".localized()
        static let preparation = "upload_data_preparation".localized()
    }

    enum Zipper {
        enum Error {
            static let kycIsNotValid = "zipper_error_kyc_invalid".localized()
            static let zipFoundationNotImported = "zipper_error_zip_foundation_not_imported".localized()
            static let zipExceedMaximumSize = "zipper_error_zip_exceed_max_size".localized()
            static let cannotCreateZip = "zipper_error_cannot_create_zip".localized()
            static let notEnoughSpace = "zipper_error_not_enough_space".localized()
            static let unknown = "zipper_error_unknown".localized()
            static let alertTitle = "zipper_error_alert_title".localized()
        }
    }

    enum Verification {
        static let title = "verification_title".localized()
        static let description = "verification_description".localized()
        static let processTitle = "verification_process_title".localized()
    }

    enum APIErrorDesc {
        static let malformedResponseJson = "api_error_malformed_json".localized()
        static let clientError = "api_error_client_error".localized()
        static let authorizationFailed = "api_error_authorization_failed".localized()
        static let unauthorizedAction = "api_error_unauthorized".localized()
        static let expectationMismatch = "api_error_data_mismatch".localized()
        static let incorrectIdentificationStatus = "api_error_incorrect_ident_status".localized()
        static let unprocessableEntity = "api_error_unprocessable_entity".localized()
        static let internalServerError = "api_error_internal_server_error".localized()
        static let requestError = "api_error_request_build_error".localized()
        static let unknownError = "api_error_unknown".localized()
        static let resourceNotFound = "api_error_resource_not_found".localized()
        static let locationAccessError = "api_error_location_permission".localized()
        static let locationError = "api_error_location_error".localized()
        static let ibanVerificationError = "api_error_iban_verification".localized()
        static let paymentFailure = "api_error_payment_failure".localized()
        static let unsupportedResponse = "SDK encountered a response that is not supported in this version"
        static let identificationNotPossible = "SDK could not identify the user. Try your fallback identification method."
    }

    enum Result {
        static let successTitle = "result_success_title".localized()
        static let successDescription = "result_success_description".localized()
        static let failedTitle = "result_failed_title".localized()
        static let failedDescription = "result_failed_description".localized()
    }
}
