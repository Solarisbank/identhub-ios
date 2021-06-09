//
//  LocationViewModel.swift
//  IdentHubSDK
//

import Foundation
import MapKit

final class LocationViewModel: BaseFourthlineViewModel {

    // MARK: - Public methods -

    func didTriggerContinue() {
        coordinator.perform(action: .upload)
    }
}

extension LocationViewModel: StepsProgressViewDataSource {

    func currentStep() -> Int {
        FourthlineProgressStep.upload.rawValue
    }
}
