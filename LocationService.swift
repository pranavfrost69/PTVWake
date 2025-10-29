import Foundation
import CoreLocation
import SwiftUI
import UserNotifications

final class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()

    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private var geofenceRegion: CLCircularRegion?
    private var alarmCallback: (() -> Void)?

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    func startUpdating() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }

    func setGeofence(center: CLLocationCoordinate2D, radius: Double, identifier: String, onAlarm: @escaping () -> Void) {
        if let old = geofenceRegion {
            locationManager.stopMonitoring(for: old)
        }
        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        geofenceRegion = region
        alarmCallback = onAlarm
        locationManager.startMonitoring(for: region)
    }

    func removeGeofence() {
        if let region = geofenceRegion {
            locationManager.stopMonitoring(for: region)
            geofenceRegion = nil
            alarmCallback = nil
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // Trigger alarm when entering geofence
        alarmCallback?()

        // Local notification
        let content = UNMutableNotificationContent()
        content.title = "Approaching your stop"
        content.body = "Wake up! You're nearly at your destination."
        content.sound = UNNotificationSound.defaultCritical

        let request = UNNotificationRequest(identifier: "ptvWakeAlarm", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}