//
//  SessionInfoProvider.swift
//  IdentHubSDK
//

import Foundation
import UIKit
import IdentHubSDKCore

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

    /// Fallback identification step type
    var fallbackIdentificationStep: IdentificationStep? { get set }

    /// IBAN retries count
    var retries: Int { get set }

    /// Accepted state of the "Terms and Conditions" agreement
    var acceptedTC: Bool { get set }

    /// Identified person phone verificatoin status
    var phoneVerified: Bool { get set }

    /// Documents list
    var documentsList: [SupportedDocument]? { get set }
    
    /// Is remote logging enabled
    var remoteLogging: Bool { get set }
    
    /// Method stored style colors to the user defaults
    /// - Parameter color: colors model
    func setStyleColors(_ color: StyleColors?)
    
    /// Method to add remote logging enable callback
    /// - Parameter callback: Closure to be called when `remoteLogging` value is set to true. Will trigger only if set from `false` to `true`
    func addEnableRemoteLoggingCallback(_ callback: @escaping () -> Void)
}

/// Count of default retries. Used if from server comes null value
let defaultRetries = 5

/// Session info provider.
final class StorageSessionInfoProvider: SessionInfoProvider {

    // MARK: Properties

    /// - SeeAlso: SessionInfoProvider.sessionToken
    var sessionToken: String

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

    /// - SeeAlso: SessionInfoProvider.fallbackIdentificationStep
    var fallbackIdentificationStep: IdentificationStep? {
        didSet {
            if let step = fallbackIdentificationStep {
                SessionStorage.updateValue(step.rawValue, for: StoredKeys.fallbackIdentStep.rawValue)
            }
        }
    }

    /// - SeeAlso: SessionInfoProvider.identificationType
    var identificationStep: IdentificationStep? {
        didSet {
            if let step = identificationStep {
                SessionStorage.updateValue(step.rawValue, for: StoredKeys.identStep.rawValue)
            }
        }
    }

    /// - SeeAlso: SessionInfoProvider.fallbackIdentificationStep
    var retries: Int = defaultRetries {
        didSet {
            SessionStorage.updateValue(retries, for: StoredKeys.retriesCount.rawValue)
        }
    }

    /// - SeeAlso: SessionInfoProvider.acceptedTC
    var acceptedTC: Bool = false {
        didSet {
            SessionStorage.updateValue(acceptedTC, for: StoredKeys.acceptedTC.rawValue)
        }
    }

    /// - SeeAlso: SessionInfoProvider.phoneVerified
    var phoneVerified: Bool = false {
        didSet {
            SessionStorage.updateValue(phoneVerified, for: StoredKeys.phoneVerified.rawValue)
        }
    }
    
    /// - SeeAlso: SessionInfoProvider.remoteLogging
    var remoteLogging: Bool = false {
        didSet {
            guard oldValue != remoteLogging else {
                return
            }
            
            SessionStorage.updateValue(remoteLogging, for: StoredKeys.remoteLogging.rawValue)

            notifyEnableRemoteLoggingObserversIfNeeded()
        }
    }

    /// - SeeAlso: SessionInfoProvider.isSuccessful
    var isSuccessful: Bool?

    /// - SeeAlso: SessionInfoProvider.documentsList
    var documentsList: [SupportedDocument]?
    
    private var enableRemoteLogginCallbacks: [() -> Void] = []

    // MARK: Init

    init(sessionToken: String) {
        self.sessionToken = sessionToken
        self.restoreValues()
        
        NotificationCenter.default.addObserver(self, selector: #selector(enteringBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    // MARK: - Public methods -
    func setStyleColors(_ color: StyleColors?) {

        if let primaryColor = color?.primary {
            SessionStorage.updateValue(primaryColor, for: StoredKeys.StyleColor.primary.rawValue)
        }

        if let primaryDarkColor = color?.primaryDark {
            SessionStorage.updateValue(primaryDarkColor, for: StoredKeys.StyleColor.primaryDark.rawValue)
        }

        if let secondaryColor = color?.secondary {
            SessionStorage.updateValue(secondaryColor, for: StoredKeys.StyleColor.secondary.rawValue)
        }
    }
    
    /// - SeeAlso: SessionInfoProvider.addEnableRemoteLoggingCallback
    func addEnableRemoteLoggingCallback(_ callback: @escaping () -> Void) {
        enableRemoteLogginCallbacks.append(callback)
        
        notifyEnableRemoteLoggingObserversIfNeeded()
    }
    
    private func notifyEnableRemoteLoggingObserversIfNeeded() {
        if remoteLogging {
            enableRemoteLogginCallbacks.forEach { $0() }
        } else {
            // TODO: We cannot disable on SBLog level yet. Waiting for implementation.
        }
    }
}

// MARK: - Private methods -

private extension StorageSessionInfoProvider {

    private func restoreValues() {

        if let token = SessionStorage.obtainValue(for: StoredKeys.token.rawValue) as? String {
            if sessionToken != token {
                clearDataAndUpdateSessionTokenValue()
                return
            }
        } else {
            clearDataAndUpdateSessionTokenValue()
            return
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

        if let identStep = SessionStorage.obtainValue(for: StoredKeys.identStep.rawValue) as? String {
            identificationStep = IdentificationStep(rawValue: identStep)
        }

        if let fallbackStep = SessionStorage.obtainValue(for: StoredKeys.fallbackIdentStep.rawValue) as? String {
            fallbackIdentificationStep = IdentificationStep(rawValue: fallbackStep)
        }

        if let retriesCount = SessionStorage.obtainValue(for: StoredKeys.retriesCount.rawValue) as? Int {
            retries = retriesCount
        }

        if let accepted = SessionStorage.obtainValue(for: StoredKeys.acceptedTC.rawValue) as? Bool {
            acceptedTC = accepted
        }

        if let verified = SessionStorage.obtainValue(for: StoredKeys.phoneVerified.rawValue) as? Bool {
            phoneVerified = verified
        }
        
        if let remoteLogging = SessionStorage.obtainValue(for: StoredKeys.remoteLogging.rawValue) as? Bool {
            self.remoteLogging = remoteLogging
        }
    }
    
    private func clearDataAndUpdateSessionTokenValue() {
        SessionStorage.clearData()
        SessionStorage.updateValue(sessionToken, for: StoredKeys.token.rawValue)
    }
    
    @objc private func enteringBackground() {
        UserDefaults.standard.synchronize()
    }
}
