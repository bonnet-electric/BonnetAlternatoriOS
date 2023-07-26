//
//  TokenGeneratorDelegate.swift
//  
//
//  Created by Ana Márquez on 12/07/2023.
//

import Foundation

public protocol TokenGeneratorDelegate {
    /// This function should return the need it token to establish and refresh the session
    /// - Returns: New/Updated token
    func refreshToken() async throws -> String
}
