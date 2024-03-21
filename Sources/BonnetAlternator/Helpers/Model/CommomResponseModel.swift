//
//  CommomResponseModel.swift
//  
//
//  Created by Ana Márquez on 20/06/2023.
//

import Foundation
import CoreLocation

struct CommomResponseModel: Codable {
    var type: `Type`?
    var platform: Platform? = .ios
    var data: DataType?
    
    enum `Type`: String, Codable {
        case handShake = "HANDSHAKE"
        case sample = "SAMPLE"
        case token = "TOKEN"
        case userLocation = "USER_LOCATION"
        case path = "PATH"
        case navigate = "NAVIGATE"
        case browser = "BROWSER"
        case loading = "LOADING"
        case filters = "FILTER"
        // Clearly mention if intercom is beeing open (TRUE) and when is close (FALSE)
        case intercom = "INTERCOM"
        case unowned
        
        init(from decoder: Decoder) throws {
            self = try .initializedOptionalWith(decoder: decoder, defaultValue: .unowned)
        }
    }

    enum Platform: String, Codable {
        case ios, web, android
    }
    
    struct DataType: Codable {
        var app_id: String? = Bundle.main.bundleIdentifier
        var key: String? = nil
        var jwt: String? = nil
        var coordinates: CLLocationCoordinate2D? = nil
        var filters: Filters? = nil
        var value: String? = nil
        var latitude: Double? = nil
        var longitude: Double? = nil
        var `operator`: String? = nil
        var setting: Bool? = nil
    }
}

extension CommomResponseModel {
    
    static func userLocation(with coordinate: CLLocationCoordinate2D) -> CommomResponseModel {
        return CommomResponseModel(type: .userLocation, data: .init(app_id: nil, key: nil, jwt: nil, value: nil, latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
}

extension Decodable where Self: RawRepresentable, RawValue: Decodable {
    static func initializedOptionalWith(decoder: Decoder, defaultValue: Self) throws -> Self {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(RawValue.self)
        return .init(rawValue: value) ?? defaultValue
    }
}
