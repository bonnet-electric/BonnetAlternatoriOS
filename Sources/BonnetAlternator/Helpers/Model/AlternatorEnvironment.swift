//
//  AlternatorEnvironment.swift
//  
//
//  Created by Ana Márquez on 28/07/2023.
//

import Foundation

public enum AlternatorEnvironment: String, Equatable {
    case staging, production
    
    internal var url: String {
        switch self {
        case .staging:
            return "https://test.alternator.bonnetapps.com"
        case .production:
            return "https://alterantor.bonnetapps.com"
        }
    }
}
