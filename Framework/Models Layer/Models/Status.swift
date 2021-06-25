//
//  Status.swift
//  IdentHubSDK
//

import Foundation

/// List of possible status cases.
///
/// pending: result of hitting IBAN verification.
/// authorizationRequired: result of async process in the web view, documents will start appearing here.
/// confirmationRequired: result of hitting documents authorization.
/// confirmed: result of hitting documents confirm.
/// successful: result of async process that happens in background.
internal enum Status: String, Decodable {
    case created = "created"
    case pending = "pending"
    case authorizationRequired = "authorization_required"
    case confirmationRequired = "confirmation_required"
    case confirmed = "confirmed"
    case successful = "successful"
    case failed = "failed"
}
