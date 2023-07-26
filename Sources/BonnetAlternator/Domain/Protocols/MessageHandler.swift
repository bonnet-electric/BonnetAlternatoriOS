//
//  MessageHandler.swift
//  
//
//  Created by Ana Márquez on 12/07/2023.
//

import Foundation

protocol MessageHandler: Any {
    func didReceive(_ response: CommomResponseModel)
    @MainActor func updateLoader(_ loading: Bool)
    func error(_ message: String)
}
