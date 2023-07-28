//
//  SecuredCommunicationService.swift
//  
//
//  Created by Ana Márquez on 21/06/2023.
//

import Foundation
import CryptoKit
import BFSecurity

protocol MessagingFormatterDelegate {
    @MainActor func formattedAndSentJsMessage(with content: String)
}

class SecuredCommunicationService {
    static let shared = SecuredCommunicationService()
    
    // MARK: - Helper formatter
    var messagingDelegate: MessagingFormatterDelegate?
    
    // Keep Shared secret during session
    private var sharedSecret: SharedSecret?
    
    // Services
    private var securityService = BFSecurityService()
    
    // MARK: - Accesible functions
    
    @MainActor
    func establishHandShake(with jsPublicKey: String, token: String, filters: Filters?) throws {
        // Generate public key
        let iOSPublicKey = self.securityService.getPublicKeyToShared()
        
        if let filters {
            debugPrint("[Bonnet Alternator] Added filters: \(filters)")
        }
        
        // Generate content data need it to stablish connection
        guard let content = try? CommomResponseModel(type: .handShake, data: .init(key: iOSPublicKey, jwt: token, filters: filters)).toString() else {
            return
        }
        
        // Create message formated
        let escapedContent = content.replacingOccurrences(of: "'", with: "\\'")
        // Sent message to webview
        self.messagingDelegate?.formattedAndSentJsMessage(with: escapedContent)
        
        // Generate Shared secret
        do {
            self.sharedSecret = try self.securityService.deriveSharedSecretKey(for: jsPublicKey)
            debugPrint("[Bonnet Alternator] Shared Secret created")
        } catch let error {
            debugPrint("[Bonnet Alternator] Shared Secret error: \(error.message)")
        }
    }
    
    // MARK: - Encrypt/Decrypt Data
    
    func encrypt(_ message: String) -> String? {
        guard let sharedSecret,
              let encryptMessage = try? self.securityService.encryptaData(message, key: sharedSecret)
        else { return nil }
        return encryptMessage
    }
    
    func decrypt<T: Codable>(_ data: String) -> Result<T, SecurityServiceError> {
        guard let sharedSecret else { return .failure(.other(message: "Not connection established")) }
        
        do {
            let decryptedData = try self.securityService.decryptData(data, key: sharedSecret)
            
            if let string = String(data: decryptedData, encoding: .utf8) {
                debugPrint("[Bonent Alternator] Decrypted data: \(string)")
            }
            
            let result: T = try T.parse(data: decryptedData)
            return .success(result)
        } catch let error {
            debugPrint("[Bonent Alternator] Decrypted data parsing error: \(error.message)")
            return .failure(.error(error))
        }
    }
}