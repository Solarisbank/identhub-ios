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

/// Various identification session types
public enum IdentificationSessionType: Int {

    /// BankID identification session type
    case bankID = 1

    /// Fourthline service identificaiton session type
    case fourthline = 2

    /// Full identification flow
    case idnow = 3

    /// Not specified method
    case unspecified = 0
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

    /// Fourthline identification process step value key
    case fourthlineStep = "FourthlineIdentificationStepKey"

    /// Fourthline selfie step result data
    case selfieData = "FourthlineSelfieDataKey"

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
