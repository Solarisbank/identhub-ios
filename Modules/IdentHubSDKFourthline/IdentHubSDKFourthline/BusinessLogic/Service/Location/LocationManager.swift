//
//  LocationManager.swift
//  IdentHubSDKFourthline
//

import Foundation
import MapKit
import IdentHubSDKCore

final class LocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = LocationManager()
    private var locationManager: CLLocationManager?
    private var requestCompletionHandler: ((Bool, Error?) -> Void)!
    private var completionLocationHandler: ((CLLocation?, Error?) -> Void)!
    private var authStatus: CLAuthorizationStatus = .notDetermined

    // MARK: - Public methods -

    func requestLocationAuthorization(completionHandler: @escaping((Bool, Error?) -> Void)) {
        fourthlineLog.debug("LocationManager.requestLocationAuthorization")
        
        self.requestCompletionHandler = completionHandler
        
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
        }
        
        let authorizationStatus: CLAuthorizationStatus
        if #available(iOS 14, *) {
            authorizationStatus = locationManager?.authorizationStatus ?? .notDetermined
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        checkLocationStatus(status: authorizationStatus)
    }

    func requestDeviceLocation(completionHandler: @escaping((CLLocation?, Error?) -> Void)) {
        fourthlineLog.debug("LocationManager.requestDeviceLocation")
        
        completionLocationHandler = completionHandler

        locationManager?.requestLocation()
    }

    // MARK: - Internal methods -

    private func checkLocationStatus(status: CLAuthorizationStatus) {
        fourthlineLog.debug("LocationManager.checkLocationStatus \(status)")
        
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
        
        fourthlineLog.assertWarn(status == .authorizedWhenInUse || status == .authorizedAlways, "LocationManager authorization status changed to \(status)")
        
        if authStatus != status {
            checkLocationStatus(status: status)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        fourthlineLog.debug("LocationManager didUpdateLocations \(locations.count)")
        
        guard let location = locations.first else {
            completionLocationHandler(nil, APIError.locationAccessError)
            return
        }

        completionLocationHandler(location, nil)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        fourthlineLog.warn("LocationManager didFailWithError \(error.localizedDescription)")
        
        completionLocationHandler(nil, error)
    }
    
    func releaseCompletionHandler() {
        fourthlineLog.debug("LocationManager releaseCompletionHandler")
        
        completionLocationHandler = nil
    }
    
    func releaseLocationAuthorizationCompletionHandler() {
        fourthlineLog.debug("LocationManager releaeRequestCompletionHandler")
        
        requestCompletionHandler = nil
    }
    
    func resetLocationManager() {
        if locationManager != nil {
            locationManager?.delegate = nil
            locationManager = nil
        }
    }
}
