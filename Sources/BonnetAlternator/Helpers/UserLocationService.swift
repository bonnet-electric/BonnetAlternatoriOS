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
    // MARK: - Published
    
    @Published var currentCoordinate: CLLocationCoordinate2D? = nil
    
    // MARK: - Parameters
    
    private let locationManager = CLLocationManager()
    private(set) var isEnabled: Bool = false
    
    override init() {
        super.init()
        
        self.locationManager.activityType = .automotiveNavigation
        self.locationManager.allowsBackgroundLocationUpdates = false
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.delegate = self
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
        case .restricted:
            print("parental control setting disallow location data")
        case .notDetermined:
            print("the location permission dialog haven't shown before, user haven't tap allow/disallow")
        @unknown default:
            print("ERROR: Unhendeled CLLocationManager Authorization status")
        }
    }
}

extension UserLocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationCoordinate = locations.last?.coordinate {
            
            if let currentCoordinate {
                let distance = currentCoordinate.distance(to: locationCoordinate)
                
                // Only update the new distance if the distance between the new and old if higher that 5
                if distance > 5 {
                    self.currentCoordinate = locationCoordinate
                }
                
            } else {
                // First user location update
                self.currentCoordinate = locationCoordinate
            }
        }
    }
    
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.isEnabled = manager.authorizationStatus != .denied && manager.authorizationStatus != .restricted
        self.locationManagerDidChangeAuthorizationStatus(manager, status: manager.authorizationStatus)
    }
}
