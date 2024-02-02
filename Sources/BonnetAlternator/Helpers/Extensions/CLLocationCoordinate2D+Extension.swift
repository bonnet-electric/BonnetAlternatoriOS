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

extension CLLocationCoordinate2D: Codable, Hashable, Equatable {
    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude + longitude)
    }
    
    // MARK: - Equatable
    static public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
      case latitude, longitude
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let latitudeValue = try container.decode(Double.self, forKey: .latitude)
        let longitudeValue = try container.decode(Double.self, forKey: .longitude)
        
        self.init(latitude: latitudeValue, longitude: longitudeValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}
