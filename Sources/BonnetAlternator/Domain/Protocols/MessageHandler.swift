//
//  MessageHandler.swift
//  
//
//  Created by Ana Márquez on 12/07/2023.
//

import Foundation

protocol MessageHandler: NSObjectProtocol {
    func didReceive(_ response: CommomResponseModel)
    func error(_ message: String)
    @MainActor func updateLoader(_ loading: Bool)
}
