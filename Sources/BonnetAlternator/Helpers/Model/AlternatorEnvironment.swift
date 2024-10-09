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
            return "https://alternator.bonnetapps.com"
        }
    }
    
    internal var profileURL: String {
        switch self {
        case .staging:
            return "https://test.bonnetapps.com/partner-api/users/profile"
        default:
            return "https://bonnetapps.com/partner-api/users/profile"
        }
    }
}
