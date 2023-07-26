//
//  File.swift
//  
//
//  Created by Ana Márquez on 20/06/2023.
//

import Foundation
import SwiftUI

struct Toast: Equatable {
    var style: Style
    var message: String
    var duration: Double = 3
    var position: Position = .bottom
    
    enum Style: Equatable {
        case error
        case warning
        case success
        case info
        
        var color: Color {
            switch self {
            case .error: return .red
            case .warning: return .yellow
            case .success: return .green
            case .info: return .blue
            }
        }
    }
    
    enum Position: Equatable {
        case bottom
        case top
    }
}
