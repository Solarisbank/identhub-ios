//
//  Localizable.swift
//  IdentHubSDKFourthline
//

import IdentHubSDKCore

internal enum Localizable {
    typealias Common = IdentHubSDKCore.Localizable.Common
    typealias APIErrorDesc = IdentHubSDKCore.Localizable.APIErrorDesc
    typealias Location = IdentHubSDKCore.Localizable.Location
    typealias Verification = IdentHubSDKCore.Localizable.Verification
    typealias Zipper = IdentHubSDKCore.Localizable.Zipper
    typealias FetchData = IdentHubSDKCore.Localizable.FetchData
    
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
        static let namirialTerms = "welcome_page_namirial_terms".localized()
        static let termsConditions = "identhub_terms_and_conditions_title".localized()
    }
    
    enum OrcaWelcome {
        static let pageTitle = "identhub_fourthline_orca_welcome_title".localized()
        static let description = "identhub_fourthline_orca_welcome_description".localized()
        static let cameraInfo = "identhub_fourthline_orca_welcome_camera_info".localized()
        static let locationInfo = "identhub_fourthline_orca_welcome_location_info".localized()
    }
    
    enum Selfie {
        static let selfieTitle = "identhub_fourthline_selfie_instructions_title".localized()
        static let scanning = "selfie_scanning".localized()
        static let detected = "selfie_detected".localized()
        static let success = "identhub_fourthline_successful_scan_title".localized()
        static let retake = "selfie_retake".localized()
        static let confirm = "selfie_confirm".localized()
        static let confirmSelfie = "selfie_confirm_selfie".localized()

        enum Warnings {
            static let faceNotInFrame = "identhub_fourthline_selfie_warning_face_in_frame".localized()
            static let faceNotDetected = "identhub_fourthline_selfie_warning_not_detected".localized()
            static let faceTooClose = "identhub_fourthline_selfie_warning_phone_too_close".localized()
            static let faceTooFar = "identhub_fourthline_selfie_warning_phone_too_far".localized()
            static let faceYawTooBig = "selfie_warning_face_camera_directly".localized()
            static let multipleFacesDetected = "selfie_warning_multiple_faces_detected".localized()
            static let deviceNotSteady = "identhub_fourthline_selfie_warning_device_steadiness".localized()
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
            static let checking = "identhub_fourthline_selfie_step_liveness_detection".localized()
            static let confirm = "selfie_liveness_confirm".localized()
            static let failed = "selfie_liveness_faild".localized()
            static let turnHeadLeft = "identhub_fourthline_selfie_scan_step_left".localized()
            static let turnHeadRight = "identhub_fourthline_selfie_scan_step_right".localized()
        }
    }

    enum Camera {
        static let permissionErrorAlertTitle = "camera_permission_error_title".localized()
        static let permissionErrorAlertMessage = "camera_permission_error_message".localized()
        static let errorMessage = "camera_error_message".localized()
        static let premissionNotGranted = "camera_permission_not_granted".localized()
    }
    
    enum DocumentScanner {

        static let title = "identhub_fourthline_doctype_description".localized()
        static let description = "identhub_fourthline_doctype_title".localized()
        static let passport = "identhub_fourthline_doctype_passport".localized()
        static let idCard = "identhub_fourthline_doctype_id_card".localized()
        static let paperID = "identhub_fourthline_doctype_paper_id".localized()
        static let successScan = "identhub_fourthline_successful_scan_title".localized()
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
            static let front = "identhub_fourthline_doc_scan_front".localized()
            static let frontAngled = "identhub_fourthline_doc_scan_angled".localized()
            static let back = "identhub_fourthline_doc_scan_back".localized()
            static let backAngled = "identhub_fourthline_doc_scan_back_angled".localized()
            static let insideLeft = "doc_scanner_side_inside_left_title".localized()
            static let insideLeftAngled = "doc_scanner_side_inside_left_angled_title".localized()
            static let insideRight = "doc_scanner_side_inside_right_title".localized()
            static let insideRightAngled = "doc_scanner_side_inside_right_angled_title".localized()
            static let undefined = "doc_scanner_side_undefined_title".localized()
        }

        enum Warning {
            static let deviceNotSteady = "identhub_fourthline_selfie_warning_device_steadiness".localized()
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
            static let title = "identhub_fourthline_doc_result_title".localized()
            static let docNumber = "identhub_fourthline_doc_result_number_input".localized()
            static let issue = "identhub_fourthline_doc_result_issue_date_input".localized()
            static let expire = "identhub_fourthline_doc_result_expiry_date_input".localized()
            static let warning = "identhub_fourthline_doc_result_description".localized()
            static let enterData = "identhub_fourthline_doc_result_empty_warning_label".localized()
            static let confirmData = "identhub_fourthline_doc_result_confirmation_warning_label".localized()
            static let expireDateMessage = "doc_scanner_info_expire_date_message".localized()
        }
        
        enum Healthcard {
            static let title = "identhub_fourthline_health_card_instructions_title".localized()
            static let description = "identhub_fourthline_health_card_instructions_description".localized()
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

    enum Upload {
        static let title = "upload_data_title".localized()
        static let description = "upload_data_description".localized()
        static let uploading = "upload_data_uploading".localized()
        static let preparation = "upload_data_preparation".localized()
        static let bottomInstruction = "identhub_fourthline_kyc_upload_bottom_notice".localized()
    }

    enum Result {
        static let successTitle = "identhub_fourthline_kyc_result_title".localized()
        static let successDescription = "identhub_fourthline_kyc_result_label".localized()
        static let failedTitle = "result_failed_title".localized()
        static let failedDescription = "result_failed_description".localized()
    }

}
