//
//  SessionInfoProvider.swift
//  IdentHubSDK
//

import Foundation

/// Describes entity capable of providing information about the session.
protocol SessionInfoProvider: AnyObject {

    /// Session token which contains partner id, client id and session id.
    var sessionToken: String { get set }

    /// Mobile number of the current user.
    var mobileNumber: String? { get set }

    /// Id of the identification.
    var identificationUID: String? { get set }

    /// Path to the payment identification provider.
    var identificationPath: String? { get set }

    /// Successful identification status
    var isSuccessful: Bool? { get set }

    /// Clears currently stored data.
    func clear()
}

/// Session info provider.
final class StorageSessionInfoProvider: SessionInfoProvider {

    // MARK: Properties

    /// - SeeAlso: SessionInfoProvider.sessionToken
    var sessionToken: String

    /// - SeeAlso: SessionInfoProvider.mobileNumber
    var mobileNumber: String?

    /// - SeeAlso: SessionInfoProvider.identificationUID
    var identificationUID: String?

    /// - SeeAlso: SessionInfoProvider.identificationPath
    var identificationPath: String?

    /// - SeeAlso: SessionInfoProvider.isSuccessful
    var isSuccessful: Bool?

    // MARK: Init

    init(sessionToken: String) {
        self.sessionToken = sessionToken
    }

    /// - SeeAlso: SessionInfoProvider.clear()
    func clear() {
        sessionToken = ""
        mobileNumber = nil
        identificationUID = nil
        identificationPath = nil
        isSuccessful = false
    }
}
