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
public enum IdentificationSessionType {
    /// BankID identification session type
    case bankID

    /// Fourthline service identificaiton session type
    case fouthline
}
