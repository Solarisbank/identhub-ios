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
public enum Status: String, Decodable, CaseIterable {
    case success = "successful"
    case failed = "failed"
    case pending = "pending"
    case processed = "processed"
    case created = "created"
    case pendingSuccess = "pending_successful"
    case pendingFailed = "pending_failed"
    case aborted = "aborted"
    case canceled = "canceled"
    case expired = "expired"
    case authorizationRequired = "authorization_required"
    case confirmationRequired = "confirmation_required"
    case confirmed = "confirmed"
    case identificationRequired = "identification_data_required"
    case rejected = "rejected"
    case fraud = "fraud"
    case unknown
}
