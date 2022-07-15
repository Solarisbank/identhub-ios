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
        SBLog.debug("LocationManager.requestLocationAuthorization")
        
        self.requestCompletionHandler = completionHandler
        
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
        }

        checkLocationStatus(status: CLLocationManager.authorizationStatus())
    }

    func requestDeviceLocation(completionHandler: @escaping((CLLocation?, Error?) -> Void)) {
        SBLog.debug("LocationManager.requestDeviceLocation")
        
        completionLocationHandler = completionHandler

        locationManager?.requestLocation()
    }

    // MARK: - Internal methods -

    private func checkLocationStatus(status: CLAuthorizationStatus) {
        SBLog.debug("LocationManager.checkLocationStatus \(status)")
        
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
        SBLog.debug("LocationManager didChangeAuthorization \(status)")
        
        SBLog.assertWarn(status == .authorizedWhenInUse || status == .authorizedAlways, "LocationManager authorization status changed to \(status)")
        
        if authStatus != status {
            checkLocationStatus(status: status)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        SBLog.debug("LocationManager didUpdateLocations \(locations.count)")
        
        guard let location = locations.first else {
            completionLocationHandler(nil, APIError.locationAccessError)
            return
        }

        completionLocationHandler(location, nil)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        SBLog.warn("LocationManager didFailWithError \(error.localizedDescription)")
        
        completionLocationHandler(nil, error)
    }
    
    func releaseCompletionHandler() {
        SBLog.debug("LocationManager releaseCompletionHandler")
        
        completionLocationHandler = nil
    }
}
