//
//  IdentHubConstants.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

/// Ident hub session result
public enum IdentificationSessionResult: Equatable {
    
    /// failure - the session has failed for some reason.
    /// - error: indicating the reason of the failure. Kept for backwards compatibility, integrators should not rely on the specifics of the error.
    case failure(APIError)

    /// onConfirm - success result of the Fourthline signing flow with identification value string in parameter
    /// - identification: identification user session identifier
    case onConfirm(identification: String)
}

/// Enumeration with all Fourthline flow steps
enum FourthlineProgressStep: Int {
    case selfie = 0, document, confirm, upload, result
}
