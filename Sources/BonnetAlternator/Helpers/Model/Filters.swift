//
//  Filters.swift
//  
//
//  Created by Ana Márquez on 24/07/2023.
//

import Foundation

struct Filters: Codable {
    let firebase_uid: String?
    let available: Bool?
    let plug: [String]?
    let min_power: Int?
    let evse_count: Int?
}
