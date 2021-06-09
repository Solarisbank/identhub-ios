//
//  LocationManager.swift
//  IdentHubSDK
//

import Foundation
import MapKit

final class LocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = LocationManager()
    private var locationManager: CLLocationManager?
    private var completionHandler: (() -> Void)!
    private var completionLocationHandler: ((CLLocation?, Error?) -> Void)!

    // MARK: - Public methods -

    func requestLocationAuthorization(completionHandler: @escaping(() -> Void)) {
        self.completionHandler = completionHandler
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestWhenInUseAuthorization()
        } else {
            checkLocationStatus(status: CLLocationManager.authorizationStatus())
        }
    }

    func requestDeviceLocation(completionHandler: @escaping((CLLocation?, Error?) -> Void)) {
        completionLocationHandler = completionHandler

        locationManager?.requestLocation()
    }

    // MARK: - Internal methods -

    private func checkLocationStatus(status: CLAuthorizationStatus) {
        guard status == .notDetermined else {
            guard status != .authorizedWhenInUse &&
                    status != .authorizedAlways else {
                if let completion = completionLocationHandler {
                    completion(nil, APIError.locationAccessError)
                }

                completionHandler()
                return
            }

            print("WARNING: Location permission might be mandatory for certain clients, please check with your team, especially when we do the zipping.")
            print("INFO: We are using the cached location while the user is checking Selfie, Document, NFC scanner or while zipping.")

            completionHandler()
            return
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationStatus(status: status)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        completionLocationHandler(location, nil)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completionLocationHandler(nil, error)
    }
}
