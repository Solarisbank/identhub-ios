//
//  IdentHubConstants.swift
//  IdentHubSDK
//

import Foundation

/// Ident hub session result
public enum IdentificationSessionResult {
    /// success - successful result with identification string in parameter
    /// - identification: identification user session identifier
    case success(identification: String)

    /// failure - result returns with error in parameter
    /// - error: enum value of the error type, based on it app should update UI
    case failure(APIError)
}

/// UserDefaults stored keys
enum StoredKeys: String {

    /// Stored initial step in UserDefaults string key
    case initialStep = "InitialSessionStepKey"

    /// Stored identification session method type key
    case identMethod = "IdentificationSessionMethodKey"

    /// Session token key 
    case token = "SessionTokenKey"

    /// Mobile number of the identification user key
    case mobileNumber = "UserMobileNumberKey"

    /// Session identification value key
    case identUID = "IdentificationUIDKey"

    /// Session identification path value key
    case identPath = "IdentificationSessionPathKey"

    /// Fallback session identification path value key
    case identStep = "IdentificationSessionStepKey"

    /// Fallback session identification path value key
    case fallbackIdentStep = "FallbackIdentificationSessionStepKey"

    /// Retries IBAN registration amount
    case retriesCount = "IdentRetriesCountKey"

    /// Accepted state of the "Terms and Conditions" agreement
    case acceptedTC = "TermsAndConditionsAcceptedKey"

    /// BankID identification session process step value key
    case bankIDStep = "BankIDIdentificationStepKey"

    /// Fourthline identification process step value key
    case fourthlineStep = "FourthlineIdentificationStepKey"

    /// Personal data value key
    case personData = "IndentificationPersonDataKey"

    /// Fourthline selfie step result data
    case selfieData = "FourthlineSelfieDataKey"

    /// Fourthline scanned document data key
    case documentData = "FourthlineDocumentDataKey"

    /// Fourthline provider data key
    case providerData = "FourthlineProviderDataKey"

    /// Device IP-address data key
    case ipAddressData = "IPAddressDataKey"

    /// Fourthline kyc zip file url
    case kycZipData = "KYCZipDataURLKey"

    /// Prepare users data
    case fetchDataStep = "FetchPersonDataProcessKey"

    /// Upload process step
    case uploadStep = "UploadProcessKey"

    /// Selfie data store keys enumeration
    enum SelfieData: String {

        case fullImage = "FullImagePathKey"

        case location = "LocationDataKey"

        case timestamp = "TimestampKey"

        case videoURL = "VideoURLKey"
    }
}

/// Enumeration with all Fourthline flow steps
enum FourthlineProgressStep: Int {
    case selfie = 0, document, confirm, upload, result
}

/// Identification steps
enum IdentificationStep: String, Codable {
    case mobileNumber = "mobile_number"
    case bankIBAN = "bank/iban"
    case bankIDIBAN = "bank_id/iban"
    case bankIDFourthline = "bank_id/fourthline"
    case bankQES = "bank/qes"
    case bankIDQUES = "bank_id/qes"
    case fourthline = "fourthline/simplified"
    case unspecified = "unspecified"
}
