//
//  LocationViewModel.swift
//  IdentHubSDK
//

import Foundation

final class LocationViewModel {

    // MARK: - Private attributes -
    private var coordinator: FourthlineIdentCoordinator

    // MARK: - Init methods -
    init (_ coordinator: FourthlineIdentCoordinator) {
        self.coordinator = coordinator
    }

    // MARK: - Public methods -

    func didTriggerQuit() {
        coordinator.perform(action: .quit)
    }
}

extension LocationViewModel: StepsProgressViewDataSource {
    func stepsCount() -> Int {
        4
    }

    func currentStep() -> Int {
        FourthlineSteps.location.rawValue
    }
}
