//
//  LogoIcon.swift
//  
//
//  Created by Ana Márquez on 11/07/2023.
//

import Foundation

/// Handle the company logo icon name and the size that should be use to be presented
public struct LogoIcon {
    let name: String
    var size: Size = .narrow
    
    public init(name: String, size: Size = .narrow) {
        self.name = name
        self.size = size
    }
    
    public enum Size {
        /// Icon sized 34x24
        case narrow
        /// Icon sized 110x24
        case wide
        
        var width: CGFloat {
            if self == .narrow { return 34.0 }
            return 110.0
        }
        
        var height: CGFloat { 34.0 }
    }
}
