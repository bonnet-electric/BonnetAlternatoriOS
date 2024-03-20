//
//  LogService.swift
//  Bonnet
//
//  Created by Ana Marquez on 30/01/2024.
//

import SwiftUI

final class LogService: ObservableObject {
    static let shared = LogService()
    
    // Structure
    
    struct Log: Identifiable {
        let id: Int
        let text: String
        let textColor: Color
        let date: Date
        
        init(text: String, color: Color, id: Int) {
            self.id = id
            self.text = text
            self.textColor = color
            self.date = Date()
        }
    }
    
    // Variables
    @Published var logs: [Log] = []
    
    // Functions
    
    func addLog(_ log: String, color: Color = .black) {
        let id = self.logs.count
        self.logs.append(.init(text: log, color: color, id: id))
        debugPrint("[Log] \(log)")
    }
    
    func removeLastLog() {
        self.logs.removeLast()
    }
    
    func clear() {
        self.logs = []
    }
}
