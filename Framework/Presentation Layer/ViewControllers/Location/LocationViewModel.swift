//
//  LocationViewModel.swift
//  IdentHubSDK
//

import Foundation
import MapKit

final class LocationViewModel: BaseFourthlineViewModel {

    // MARK: - Public attributes -
    var onUpdateLocation: ((Bool) -> Void)?
    var onDisplayError: ((Error?) -> Void)?

    // MARK: - Public methods -

    func startLocationHandler() {
        onUpdateLocation?(false)

        LocationManager.shared.requestLocationAuthorization {
            LocationManager.shared.requestDeviceLocation { [weak self] location, error in
                guard let location = location else {

                    if let errorHandler = self?.onDisplayError {
                        errorHandler(error)
                    }
                    return
                }

                KYCContainer.shared.update(location: location)

                DispatchQueue.main.async {
                    self?.onUpdateLocation?(true)
                }
            }
        }
    }

    func didTriggerContinue() {
        coordinator.perform(action: .upload)
    }
}

extension LocationViewModel: StepsProgressViewDataSource {

    func currentStep() -> Int {
        FourthlineSteps.upload.rawValue
    }
}
