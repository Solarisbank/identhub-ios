//
//  VerifiableViewModelDelegate.swift
//  IdentHubSDK
//

import Foundation

/// Delegate which informs about the state of the verifiaction.
internal protocol VerifiableViewModelDelegate: AnyObject {

    /// Called when the verification started.
    func verificationStarted()

    /// Called when the verification was successful.
    func verificationSucceeded()

    /// Called when the verification failed.
    func verificationFailed()
}
