//
//  SecuredCommunicationService.swift
//  
//
//  Created by Ana Márquez on 21/06/2023.
//

import Foundation
import CryptoKit
import CoreLocation
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
    func establishHandShake(with jsPublicKey: String, 
                            token: String,
                            coordinates: CLLocationCoordinate2D?,
                            filters: Filters?) throws
    {
        // Generate public key
        let iOSPublicKey = self.securityService.getPublicKeyToShared()
        
        if let filters {
            debugPrint("[Bonnet Alternator] Added filters: \(filters)")
        }
        
        if let coordinates {
            debugPrint("[Bonnet Alternator] Added coordinates: \(coordinates)")
            LogService.shared.addLog("Send handshake with coordinates")
        } else {
            LogService.shared.addLog("Send handshake without coordinates")
        }
        
        // Generate content data need it to stablish connection
        let data = CommomResponseModel(type: .handShake, data: .init(key: iOSPublicKey, jwt: token, coordinates: coordinates, filters: filters))
        guard let content = try? data.toString() else { return }
        
        // Print app id to confirm proper set up
        if let appId = data.data?.app_id {
            debugPrint("[Bonnet Alternator] App id: \(appId)")
        }
        
        // Create message formated
        let escapedContent = content.replacingOccurrences(of: "'", with: "\\'")
        // Sent message to webview
        self.messagingDelegate?.formattedAndSentJsMessage(with: escapedContent)
        
        // Generate Shared secret
        do {
            self.sharedSecret = try self.securityService.deriveSharedSecretKey(for: jsPublicKey)
            debugPrint("[Bonnet Alternator] Shared Secret created")
            LogService.shared.addLog("Shared Secret created")
        } catch let error {
            LogService.shared.addLog("Shared Secret error: \(error.localizedDescription)")
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
