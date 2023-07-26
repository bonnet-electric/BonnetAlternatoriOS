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
    }

    enum Platform: String, Codable {
        case ios
        case web
        case android
    }
    
    struct DataType: Codable {
        var app_id: String? = "com.bonnet"
        var key: String? = nil
        var jwt: String? = nil
        var filters: Filters? = nil
        var value: String? = nil
        var latitude: Double? = nil
        var longitude: Double? = nil
        var setting: Bool? = nil
    }
}
