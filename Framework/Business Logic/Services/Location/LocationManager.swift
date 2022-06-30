//
//  LocationManager.swift
//  IdentHubSDK
//

import Foundation
import MapKit

final class LocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = LocationManager()
    private var locationManager: CLLocationManager?
    private var requestCompletionHandler: ((Bool, Error?) -> Void)!
    private var completionLocationHandler: ((CLLocation?, Error?) -> Void)!
    private var authStatus: CLAuthorizationStatus = .notDetermined

    // MARK: - Public methods -

    func requestLocationAuthorization(completionHandler: @escaping((Bool, Error?) -> Void)) {
        self.requestCompletionHandler = completionHandler
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
        }

        checkLocationStatus(status: CLLocationManager.authorizationStatus())
    }

    func requestDeviceLocation(completionHandler: @escaping((CLLocation?, Error?) -> Void)) {
        completionLocationHandler = completionHandler

        locationManager?.requestLocation()
    }

    // MARK: - Internal methods -

    private func checkLocationStatus(status: CLAuthorizationStatus) {
        authStatus = status

        switch status {
        case .authorizedAlways,
             .authorizedWhenInUse:
            requestCompletionHandler(true, nil)
        case .denied,
             .restricted:
            if let completion = completionLocationHandler {
                completion(nil, APIError.locationAccessError)
            } else if let completion = requestCompletionHandler {
                completion(false, APIError.locationAccessError)
            }
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        @unknown default:
            locationManager?.requestWhenInUseAuthorization()
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if authStatus != status {
            checkLocationStatus(status: status)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            completionLocationHandler(nil, APIError.locationAccessError)
            return
        }

        completionLocationHandler(location, nil)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completionLocationHandler(nil, error)
    }
    
    func releaseCompletionHandler() {
        completionLocationHandler = nil
    }
}
