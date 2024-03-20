//
//  UserLocationService.swift
//  
//
//  Created by Ana Márquez on 20/06/2023.
//

import Foundation
import CoreLocation
import MapKit

class UserLocationService: NSObject, ObservableObject {
    static let shared: UserLocationService = .init()
    
    // MARK: - Published
    @Published var currentCoordinate: CLLocationCoordinate2D? = nil
    @Published var authorizationStatus: CLAuthorizationStatus = .denied
    
    // MARK: - Parameters
    private let locationManager = CLLocationManager()
    private(set) var isEnabled: Bool = false
    // Coordinates debouncer
    private let userLocationDebouncer = Debouncer<CLLocationCoordinate2D?>()
    
    // MARK: - Init
    
    override init() {
        super.init()
        
        self.locationManager.distanceFilter = 5
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.delegate = self
        self.authorizationStatus = self.locationManager.authorizationStatus
        self.addListeners()
    }
    
    deinit {
        self.userLocationDebouncer.cancel()
    }
    
    private func addListeners() {
        self.userLocationDebouncer.debounce(for: .seconds(4), scheduler: DispatchQueue.main) { newCoordinates in
            LogService.shared.addLog("Debouncer sent new location")
            self.currentCoordinate = newCoordinates
        }
    }
    
    // MARK: - Structures
    
    internal enum UserLocationError: Error {
        case notEnabled
        case needAskUserPermission
        case userDidNotAllowed
    }
    
    // MARK: - Public access
    
    public func askUserPermissionForWhenInUseAuthorizationIfNeeded() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Internal
    
    @discardableResult
    internal func startUpdatingLocation() -> UserLocationError? {
        if !isEnabled {
            print("ERROR: location service is not enabled")
            return .notEnabled
        }
        
        let status = self.locationManager.authorizationStatus
        if (status == .denied || status == .restricted) {
            // show alert to user telling them they need to allow location data to use some feature of your app
            return .userDidNotAllowed
        }
        
        // if haven't show location permission dialog before, show it to user
        if status == .notDetermined {
            self.locationManager.requestAlwaysAuthorization()
            
            // if you want the app to retrieve location data even in background, use requestAlwaysAuthorization
            // self.locationManager.requestAlwaysAuthorization()
            return .needAskUserPermission
        }
        
        self.locationManager.startUpdatingLocation()
        return nil
    }
    
    internal func locationManagerDidChangeAuthorizationStatus(_ manager: CLLocationManager, status: CLAuthorizationStatus) {
        print("location manager authorization status changed")
        
        switch status {
        case .authorizedAlways:
            print("user allow app to get location data when app is active or in background")
            self.startUpdatingLocation()
        case .authorizedWhenInUse:
            print("user allow app to get location data only when app is active")
            self.startUpdatingLocation()
        case .denied:
            print("user tap 'disallow' on the permission dialog, cant get location data")
            // Clear current coordinate if user have denied location
            self.currentCoordinate = nil
        case .restricted:
            print("parental control setting disallow location data")
            // Clear current coordinate if user have denied location
            self.currentCoordinate = nil
        case .notDetermined:
            print("the location permission dialog haven't shown before, user haven't tap allow/disallow")
            // Clear current coordinate if user have denied location
            self.currentCoordinate = nil
        @unknown default:
            print("ERROR: Unhendeled CLLocationManager Authorization status")
        }
        
        // Only update if status changed
        if status != self.authorizationStatus {
            self.authorizationStatus = status
        }
    }
}

extension UserLocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let clLocation = locations.last {
            if clLocation.horizontalAccuracy <= manager.desiredAccuracy {
                if let oldLocation = self.currentCoordinate {
                    let distance = oldLocation.distance(to: clLocation.coordinate)
                    // We will only update the user location if the position change for at least 5 meters
                    guard distance > 5 else { 
                        LogService.shared.addLog("New location under 5 meters")
                        return }
                    // Sent to debouncer to handle updates
                    LogService.shared.addLog("New location added to debouncer")
                    self.userLocationDebouncer.send(clLocation.coordinate)
                    return
                }
            }
            
            if self.currentCoordinate == nil {
                // If this is the first fetch we just assign the values directly
                LogService.shared.addLog("Added first coordinates")
                self.currentCoordinate = clLocation.coordinate
            }
        }
    }
    
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.isEnabled = manager.authorizationStatus != .denied && manager.authorizationStatus != .restricted
        self.locationManagerDidChangeAuthorizationStatus(manager, status: manager.authorizationStatus)
    }
}

extension CLAuthorizationStatus {
    // Check is current status allow any type of location tracking
    var permissionForLocationTrackingGranted: Bool {
        switch self {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default: return false
        }
    }
}
