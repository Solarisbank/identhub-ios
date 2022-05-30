//
//  BaseFourthlineViewModel.swift
//  IdentHubSDK
//

import Foundation

internal class BaseFourthlineViewModel: NSObject {

    // MARK: - Private attributes -
    weak var coordinator: FourthlineIdentCoordinator?

    // MARK: - Init methods -

    /// Init method with flow coordinator
    /// - Parameter flowCoordinator: identification process flow coordinator
    init (_ coordinator: FourthlineIdentCoordinator) {
        self.coordinator = coordinator
    }

    // MARK: - Public methods -

    func didTriggerQuit() {
        coordinator?.perform(action: .quit)
    }
}
