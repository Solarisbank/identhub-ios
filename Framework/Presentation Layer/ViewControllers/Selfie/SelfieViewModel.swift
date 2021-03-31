//
//  SelfieViewModel.swift
//  IdentHubSDK
//

import Foundation

final internal class SelfieViewModel {

    // MARK: - Properties -
    private var flowCoordinator: FourthlineIdentCoordinator

    // MARK: - Init -

    /// Init method with flow coordinator
    /// - Parameter flowCoordinator: identification process flow coordinator
    init(flowCoordinator: FourthlineIdentCoordinator) {
        self.flowCoordinator = flowCoordinator
    }

    // MARK: - Public methods -
    func didTriggerCloseProcess() {
        self.flowCoordinator.perform(action: .quit)
    }
}
