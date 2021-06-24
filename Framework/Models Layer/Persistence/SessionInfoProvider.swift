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

    /// Identification step type
    var identificationStep: IdentificationStep? { get set }

    /// Clears currently stored data.
    func clear()
}

/// Session info provider.
final class StorageSessionInfoProvider: SessionInfoProvider {

    // MARK: Properties

    /// - SeeAlso: SessionInfoProvider.sessionToken
    var sessionToken: String {
        didSet {
            SessionStorage.updateValue(sessionToken, for: StoredKeys.token.rawValue)
        }
    }

    /// - SeeAlso: SessionInfoProvider.mobileNumber
    var mobileNumber: String? {
        didSet {
            SessionStorage.updateValue(mobileNumber!, for: StoredKeys.mobileNumber.rawValue)
        }
    }

    /// - SeeAlso: SessionInfoProvider.identificationUID
    var identificationUID: String? {
        didSet {
            SessionStorage.updateValue(identificationUID!, for: StoredKeys.identUID.rawValue)
        }
    }

    /// - SeeAlso: SessionInfoProvider.identificationPath
    var identificationPath: String? {
        didSet {
            SessionStorage.updateValue(identificationPath!, for: StoredKeys.identPath.rawValue)
        }
    }

    /// - SeeAlso: SessionInfoProvider.isSuccessful
    var isSuccessful: Bool?

    /// - SeeAlso: SessionInfoProvider.identificationType
    var identificationStep: IdentificationStep?

    // MARK: Init

    init(sessionToken: String) {
        self.sessionToken = sessionToken
        self.restoreValues()
    }

    /// - SeeAlso: SessionInfoProvider.clear()
    func clear() {
        sessionToken = ""
        mobileNumber = nil
        identificationUID = nil
        identificationPath = nil
        isSuccessful = false

        SessionStorage.clearData()
    }
}

// MARK: - Private methods -

private extension StorageSessionInfoProvider {

    private func restoreValues() {

        if let token = SessionStorage.obtainValue(for: StoredKeys.token.rawValue) as? String {
            if sessionToken != token {
                SessionStorage.clearData()
                return
            }
        }

        if let number = SessionStorage.obtainValue(for: StoredKeys.mobileNumber.rawValue) as? String {
            mobileNumber = number
        }

        if let uid = SessionStorage.obtainValue(for: StoredKeys.identUID.rawValue) as? String {
            identificationUID = uid
        }

        if let path = SessionStorage.obtainValue(for: StoredKeys.identPath.rawValue) as? String {
            identificationPath = path
        }
    }
}
