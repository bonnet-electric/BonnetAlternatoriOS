//
//  Encodable+String.swift
//  
//
//  Created by Ana Márquez on 20/06/2023.
//

import Foundation

extension Encodable {
    
    /// Giving encodable object transformed to readable string to be able to share it
    /// - Returns: Object to string
    func toString() throws -> String {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(decoding: data, as: UTF8.self)
    }
}
