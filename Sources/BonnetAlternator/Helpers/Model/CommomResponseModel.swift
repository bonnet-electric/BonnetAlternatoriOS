//
//  CommomResponseModel.swift
//  
//
//  Created by Ana Márquez on 20/06/2023.
//

import Foundation

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
        case ios
        case web
        case android
    }
    
    struct DataType: Codable {
        var app_id: String? = Bundle.main.bundleIdentifier
        var key: String? = nil
        var jwt: String? = nil
        var filters: Filters? = nil
        var value: String? = nil
        var latitude: Double? = nil
        var longitude: Double? = nil
        var `operator`: String? = nil
        var setting: Bool? = nil
    }
}

extension Decodable where Self: RawRepresentable, RawValue: Decodable {
    static func initializedOptionalWith(decoder: Decoder, defaultValue: Self) throws -> Self {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(RawValue.self)
        return .init(rawValue: value) ?? defaultValue
    }
}
