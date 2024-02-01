//
//  CLLocationCoordinate2D+Extension.swift
//  
//
//  Created by Ana Márquez on 01/02/2024.
//

import CoreLocation

extension CLLocationCoordinate2D {
    
    func distance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
}
