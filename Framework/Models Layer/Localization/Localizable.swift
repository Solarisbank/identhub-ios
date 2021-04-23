//
//  Localizable.swift
//  IdentHubSDK
//

import Foundation

enum Localizable {
    enum IdentificationProgressView {
        static let identificationProgress = "Identification progress"
        static let phoneVerification = "Phone verification"
        static let bankVerification = "Bank verification"
        static let documents = "Sign documents"
    }

    enum Common {
        static let next = "Next"
        static let quit = "Quit"
        static let continueBtn = "Continue"
        static let back = "Back"
        static let poweredBySolarisBank = "Powered by Solarisbank"
        static let verifying = "Veryfing..."
        static let downloadAllDocuments = "Download all documents"
        static let dismiss = "Dismiss"
        static let tryAgain = "Try again"
        static let cancel = "Cancel"
        static let settings = "Settings"
        static let defaultErr = "Something went wrong"
    }

    enum Quiting {
        static let title = "Are you sure you want to quit onboarding process?"
        static let description = "Your progress will be lost. You will be required to repeat the steps next time."
        static let stay = "Stay"
    }

    enum StartIdentification {
        static let startIdentification = "Start identification"
        static let instructionDisclaimer = "In order to complete the identification process, you will be asked to:"
        static let instructionSteps = "1. Verify your phone number with TAN. \n2. Identify yourself using your bank account. \n3. Read and sign proper consents, no need to print."
        static let followVerificationForNumber = "Please follow the verification of your phone number to continue."
        static let sendVerificationCode = "Send verification code"
    }

    enum PhoneVerification {
        static let enterCode = "Enter the 6-digit code sent to"
        static let requestNewCodeTimer = "Request a new code in"
        static let sendNewCode = "Send new code"
        static let wrongTan = "Wrong TAN. You need to request a new TAN and try again."
        static let submitCode = "Submit code"
        static let requestNewCode = "Request new code"

        enum Success {
            static let title = "Phone verification successful"
            static let description = "Continue to identify yourself with a bank account."
            static let action = "Begin Bank Identification"
        }

        enum Error {
            static let title = "Phone verification error"
            static let description = "Provided TAN is not valid."
            static let action = "Retry TAN verification"
        }
    }

    enum BankVerification {
        enum IBANVerification {
            static let personalAccountDisclaimer = "Please provide the IBAN number of your personal bank account."
            static let joinedAccountsDisclaimer = "Please note, that joined accounts will not pass the identification requirements."
            static let IBAN = "IBAN"
            static let IBANplaceholder = "e.g. DE21 1234  3456 4567 5678 6789"
            static let wrongIBANFormat = "IBAN format is not valid!"
            static let initiatePaymentVerification = "Initiate Payment Verification"
        }

        enum PaymentVerification {
            static let establishingSecureConnection = "Establishing secure connection to your bank…"
            static let processingVerification = "Processing verification…"

            enum Success {
                static let title = "Payment verification successful"
                static let description = "Continue to sign documents to finish your identification process."
                static let action = "Continue"
            }

            enum Error {
                static let title = "Payment verification error"
                static let technicalIssueDescription = "Unfortunately a technical error occurred. Please try again."
                static let action = "Retry IBAN verification"
            }
        }
    }

    enum SignDocuments {
        enum ConfirmApplication {
            static let confirmYourApplication = "Confirm your application"
            static let description = "To finalise the process, please read following documents and sign it with a TAN sent to your mobile phone number."
            static let sendCodeToSign = "Send code to sign"
        }

        enum Sign {
            static let transactionInfoPartOne = "Your transaction ID is "
            static let transactionInfoPartTwo = "\nMake sure it is the same in SMS you just received."
            static let submitAndSign = "Submit and sign"
            static let applicationIsBeingProcessed = "Your application is being processed..."
            static let downloadDocuments = "You will be able to download all of the signed documents soon."
        }
    }

    enum FinishIdentification {
        static let identificationSuccessful = "Identification successful!"
        static let description = "You have completed the identification process! \nDownload documents and save in secure place, for future reference."
        static let finish = "Finish"
    }

    enum TermsConditions {
        static let description = "In order to proceed, please carefully read and agree to the Privacy Statement and Terms & Conditions policies"
        static let privacyText = "Privacy Statement"
        static let termsText = "Terms & Conditions"
        static let agreementLinks = "I agree to the \(TermsConditions.privacyText) & \(TermsConditions.termsText)"
        static let continueBtn = "Continue"
    }

    enum Welcome {
        static let cameraTitle = "Smile for the camera"
        static let cameraDesc = "Your selfie will be compared to the one in your ID document. Don’t worry, it’s never going to see the light of day, promise!"

        static let documentTitle = "Scan your ID document"
        static let documentDesc = """
        With this we can make sure that you’re really who
        you say you are and avoid identity theft.
        """

        static let locationTitle = "Submit your case"
        static let locationDesc = """
        Last thing you need to do is enabling your location
        & submitting your case!
        How easy it that?
        """
    }

    enum Selfie {
        static let selfieTitle = "Take a selfie"
        static let scanning = "scanning..."
        static let detected = "face detected"
        static let success = "Scan Successful"
        static let retake = "Retake"
        static let confirm = "Confirm"
        static let confirmSelfie = "Confirm Selfie"

        enum Warnings {
            static let faceNotInFrame = "Fit face in frame"
            static let faceNotDetected = "Face not detected"
            static let faceTooClose = "Move the phone farther"
            static let faceTooFar = "Move the phone closer"
            static let faceYawTooBig = "Face the camera directly"
            static let multipleFacesDetected = "Multiple faces detected"
            static let deviceNotSteady = "Device not steady"
            static let noFace = "Looking for a face"
        }

        enum Errors {
            static let failed = "selfie failed"
            static let timeout = "Photo timed out"
            static let faceDisappeared = "Face disappeared"
            static let cameraPermissionNotGranted = "Camera permission required"
            static let manualSelfieNotAllowed = "Manual selfie is not allowed"
            static let recordingFailed = "Something went wrong"
            static let scannerInterrupted = "Scanner was interrupted"
            static let unknown = "Something went wrong"
            static let alertTitle = "Selfie scan failed"
            static let alertMessage = "It was not possible to take your selfie.\n\nThis process is mandatory for your onboarding process."
        }

        enum Liveness {
            static let title = "Liveness check"
            static let checking = "liveness check..."
            static let confirm = "liveness confirm"
            static let failed = "liveness check failed"
            static let turnHeadLeft = "Turn your head left"
            static let turnHeadRight = "Turn your head right"
        }
    }

    enum Camera {
        static let permissionErrorAlertTitle = "Camera permission denied"
        static let permissionErrorAlertMessage = "Scanner can't be started without camera permission, please allow it"
        static let errorMessage = "ERROR: In order to use vision scanners you need to grant camera permission."
        static let premissionNotGranted = "Camera permission required"
    }

    enum DocumentScanner {

        static let title = "Your ID-document"
        static let description = "choose your document type"
        static let passport = "Passport"
        static let idCard = "ID Card"
        static let successScan = "scan successful"
        static let scanning = "scanning..."
        static let scanFailed = "scan failed"

        enum DocFileSide {

            static let front = "front"
            static let back = "back"
            static let insideLeft = "inside left"
            static let insideRight = "inside right"
        }

        enum Warning {
            static let deviceNotSteady = "Device not steady"
            static let tooDark = "Too dark"
        }

        enum Error {
            static let scannerInterrupted = "Scanner was interrupted"
            static let timeout = "Scan timed out"
        }

        enum Information {
            static let title = "Document information"
            static let docNumber = "document number"
            static let birth = "date of birth"
            static let expire = "document expiry date"
            static let warning = "Please confirm if your data derived properly from the document scan"
        }
    }
}
