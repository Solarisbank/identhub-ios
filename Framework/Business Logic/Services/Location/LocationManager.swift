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

    func checkLocationStatus(status: CLAuthorizationStatus) {
        guard status == .notDetermined else {
            guard status != .authorizedWhenInUse &&
                    status != .authorizedAlways else {
                completionHandler()
                return
            }

            print("🥲WARNING: Location permission might be mandatory for certain clients, please check with your team, especially when we do the zipping.")
            print("🤖INFO: We are using the cached location while the user is checking Selfie, Document, NFC scanner or while zipping.")

            completionHandler()
            return
        }
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationStatus(status: status)
    }
}
