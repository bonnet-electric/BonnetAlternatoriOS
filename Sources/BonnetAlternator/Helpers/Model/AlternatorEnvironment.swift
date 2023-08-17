//
//  AlternatorEnvironment.swift
//  
//
//  Created by Ana Márquez on 28/07/2023.
//

import Foundation

public enum AlternatorEnvironment: String, Equatable {
    case staging, production, internalTesting
    
    internal var url: String {
        switch self {
        case .staging:
            return "https://test5.alternator.bonnetapps.com/"
        case .production:
            return "https://alternator.bonnetapps.com/"
        case .internalTesting:
            return "https://test.alternator.bonnetapps.com"
        }
    }
}
