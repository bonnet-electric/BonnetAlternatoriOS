//
//  WebService.swift
//  
//
//  Created by Ana Márquez on 20/06/2023.
//

import Foundation
import WebKit
import SwiftUI
import CoreLocation
import BFSecurity

final class WebService: NSObject {
    
    // MARK: - Parameters
    var connectionCompleted: Completion = nil
    
    private let webView: WKWebView
    
    // MARK: - Helpers
    private var messageHandler: MessageHandler?
    private let communicationService: SecuredCommunicationService = .shared
    private let userDefaultsHelper: UsersDefaultHelper = .shared
    private let userLocationService: UserLocationService = .shared
    
    var tokenDelegate: TokenGeneratorDelegate?
    
    init(webView: WKWebView) {
        self.webView = webView
        super.init()
        self.communicationService.messagingDelegate = self
    }
    
    deinit {
        debugPrint("[Alternator] [WS] Deallocated")
        self.removeListeners()
    }
    
    // MARK: - Function
    
    /// Add neccesary listener to be able to receive messages from webView
    /// - Parameter delegate: Delegate to handle received messages
    func addListeners(_ delegate: MessageHandler?) {
        self.messageHandler = delegate
        
        let contentController = self.webView.configuration.userContentController
        contentController.removeAllScriptMessageHandlers()
        contentController.removeAllUserScripts()
        // Add the message delegate listener to the content controller
        contentController.add(self, name: "toggleMessageHandler")
        
        // TODO: Remove if it doesn't work
        let source = "function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); } window.console.log = captureLog;"
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(script)
        contentController.add(self, name: "logHandler")
    }
    
    func removeListeners() {
        self.messageHandler = nil
        
        let contentController = self.webView.configuration.userContentController
        contentController.removeAllScriptMessageHandlers()
        contentController.removeAllUserScripts()
    }
    
    /// Prepare common string to be injected on the required format to the webView
    /// - Parameter message: Common string (Not format need it)
    @MainActor
    func post(_ message: String, includeFormat: Bool = true, encrypted: Bool) {
        let formattedMessage = includeFormat ? "{\"message\":\"\(message)\"}" : message
        var escapedMessage = formattedMessage.replacingOccurrences(of: "'", with: "\\'")
        
        if encrypted,
           let encryptedMessage = self.communicationService.encrypt(formattedMessage)
        {
            escapedMessage = encryptedMessage
        }
        self.formattedAndSentJsMessage(with: escapedMessage)
    }
    
    // MARK: - Handle regeneration of token
    
    internal func refreshToken() async {
        do {
            guard let newToken = try await self.tokenDelegate?.refreshToken() else {
                self.messageHandler?.error("We couldn't refresh the session")
                return
            }
            
            let message = try CommomResponseModel(type: .token, data: .init(value: newToken)).toString()
            await self.post(message, includeFormat: false, encrypted: true)
            
        } catch let error {
            self.messageHandler?.error(error.localizedDescription)
        }
    }
}

extension WebService: MessagingFormatterDelegate {
    @MainActor
    func formattedAndSentJsMessage(with content: String) {
        let jsCode = "javascript:(function() { " +
        "if (typeof window.postMessage === 'function') { " +
        "window.postMessage('\(content)'); " +  "} " + "})()"
        self.webView.evaluateJavaScript(jsCode)
    }
}

extension WebService: WKScriptMessageHandler {
    
    internal func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "logHandler" {
            if let body = message.body as? String,
               !body.contains("key")
            {
                debugPrint("[Alternator] [WS] LOG: \(message.body as? String)")
            }
            return
        }
        
        guard let body = message.body as? String,
              let data = body.data(using: .utf8)
        else {
            self.messageHandler?.error("Body message corrupted")
            return
        }
        
        Task {
            do {
                let result = try CommomResponseModel.parse(data: data)
                
                // If type is handshake we handle it from here, we don't send it to the view
                if result.type == .handShake,
                   let jsPublicKey = result.data?.key
                {
                    // Get user profile and filters from userdefauls
                    let userProfile = self.userDefaultsHelper.getString(forKey: .userProfile)
                    let filters: Filters? = self.userDefaultsHelper.get(forKey: .filters)
                    // Get user coordinates
                    let coordinates: CLLocationCoordinate2D? = self.userLocationService.currentCoordinate
                    
                    if userProfile == nil {
                        // If the users profile is empty we need to get the users token
                        guard let newToken = try await self.tokenDelegate?.refreshToken() else {
                            self.messageHandler?.error("We couldn't refresh the session")
                            return
                        }
                        
                        try self.communicationService.establishHandShake(with: jsPublicKey, token: newToken, coordinates: coordinates, user: userProfile, filters: filters)
                        
                    } else {
                        // If the users profile contains data, proceed with handshake without token
                        try self.communicationService.establishHandShake(with: jsPublicKey, token: nil, coordinates: coordinates, user: userProfile, filters: filters)
                    }
                    
                    self.connectionCompleted?()
                }
                
            } catch let error {
                debugPrint("[Bonent Alternator] [Response] received message error: \(error.message)")
                
                let decryptedResult: Result<CommomResponseModel, SecurityServiceError> = self.communicationService.decrypt(body)
                
                switch decryptedResult {
                case .success(let result):
                    
                    if result.type == .unowned {
                        debugPrint("[Bonent Alternator] [Response] received message with unowned type: \(body)")
                        return
                    }
                    
                    if let type = result.type?.rawValue {
                        debugPrint("[Bonent Alternator] [Response] received message of type: \(type)")
                    }
                    
                    if result.type == .token {
                        await self.refreshToken()
                        return
                    }
                    
                    if result.type == .loading {
                        let isLoading = result.data?.setting ?? false
                        self.messageHandler?.updateLoader(isLoading)
                        return
                    }
                    
                    if result.type == .filters {
                        guard let filters = result.data?.filters else { return }
                        self.userDefaultsHelper.set(filters, forKey: .filters)
                        return
                    }
                    
                    if result.type == .path {
                        guard let path = result.data?.value else { return }
                        self.userDefaultsHelper.set(SavedPath(path: path), forKey: .userAlternatorPath)
                    }
                    
                    self.messageHandler?.didReceive(result)
                    
                case .failure(let decryptedError):
                    self.messageHandler?.error("Decrypted error: \(decryptedError.message)")
                }
            }
        }
    }
}
