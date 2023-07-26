//
//  SavedPath.swift
//  
//
//  Created by Ana Márquez on 12/07/2023.
//

import Foundation

struct SavedPath: Codable {
    let path: String
    let date: Date
    
    init(path: String) {
        self.path = path
        self.date = Date()
    }
    
    func canBeUsed() -> Bool {
        let today = Date()
        let distance = Calendar.current.dateComponents([.hour], from: date, to: today)
        
        if let hours = distance.hour, hours < 12 {
            return true
        }
        
        return false
    }
}
