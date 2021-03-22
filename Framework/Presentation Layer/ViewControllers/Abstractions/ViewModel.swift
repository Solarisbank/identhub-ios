//
//  ViewModel.swift
//  IdentHubSDK
//

import Foundation

/// Base for ViewModel.
internal protocol ViewModel: AnyObject {

    /// Flow manager backing up the navigation.
    var flowCoordinator: BankIDCoordinator { get set }

    /// Verification service backing up the data.
    var verificationService: VerificationService { get set }

    /// Close the flow.
    func quit()
}

extension ViewModel {

    /// - SeeAlso: ViewModel.quit()
    func quit() {
        flowCoordinator.perform(action: .quit)
    }
}
