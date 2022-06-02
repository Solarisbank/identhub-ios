//
//  StartIdentificationViewModel.swift
//  IdentHubSDK
//

import Foundation

/// ViewModel which backs up the start identification view controller.
final internal class StartIdentificationViewModel: NSObject {

    private weak var flowCoordinator: BankIDCoordinator?

    init(flowCoordinator: BankIDCoordinator) {
        self.flowCoordinator = flowCoordinator
    }

    // MARK: Methods

    /// Go to send code screen.
    func startIdentification() {
        flowCoordinator?.perform(action: .phoneVerification)
    }

    /// Quit the flow.
    func quit() {
        flowCoordinator?.perform(action: .quit)
    }
}
