//
//  AlternatorViewModel.swift
//  
//
//  Created by Ana Márquez on 20/06/2023.
//

#if os(iOS)
import Foundation
import WebKit
import SwiftUI
import Combine

class AlternatorViewModel: NSObject, ObservableObject {
    // MARK: - Published
    @Published var toast: Toast? = nil
    @Published var sendMessageDisable: Bool = true
    @Published var isLoading: Bool = true
    @Published var allowKeyboardChanges: Bool = true
    
    // MARK: - Parameters
    let webView: WKWebView
    let environment: AlternatorEnvironment
    private var cancellables: Set<AnyCancellable> = []
    private let urlString: String
    
    // MARK: Keyboard helper
    internal var isIntercomOpen: Bool = false
    
    // MARK: - Services
    private let webService: WebService
    private let userLocationService: UserLocationService
    private let userDefaultHelper = UsersDefaultHelper.shared
    
    // MARK: - Initialisation
    init(tokenDelegate: TokenGeneratorDelegate?) {
        // Initialise webview with configuration
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        let newWebView = WKWebView(frame: .zero, configuration: configuration)
        self.webView = newWebView
        // Initialise web service with new webview
        self.webService = .init(webView: newWebView)
        
        self.userLocationService = UserLocationService()
        
        // Configure environment with set values
        if let envString = UsersDefaultHelper.shared.getString(forKey: .environment),
           let environment = AlternatorEnvironment(rawValue: envString)
        {
            self.environment = environment
        } else {
            self.environment = .production
        }
        // Configure url based on the environment
        self.urlString = self.environment.url
        debugPrint("[Bonnet Alternator] Environment: \(self.environment.rawValue)")
        
        super.init()
        self.webService.tokenDelegate = tokenDelegate
        self.addListeners()
    }
    
    deinit {
        self.cancellables.removeAll()
    }
    
    private func addListeners() {
        // Listen to the successful connection confirmation
        self.webService.connectionCompleted = { [weak self] in
            guard let self else { return }
            Task {
                await MainActor.run(body: {
                    self.sendMessageDisable = false
                    self.userLocationService.askUserPermissionForWhenInUseAuthorizationIfNeeded()
                })
            }
        }
        
        // Listen to user's current location
        self.userLocationService.$currentCoordinate.receive(on: DispatchQueue.main).sink { [weak self] newValue in
            guard let self,
                  let coordinate = newValue,
                  self.sendMessageDisable == false
            else { return }
            Task { await self.updateLocation(with: coordinate) }
        }.store(in: &cancellables)
    }
}

extension AlternatorViewModel {
    
    // MARK: - Variables
    private var savedPath: SavedPath? {
        self.userDefaultHelper.get(forKey: .userAlternatorPath)
    }
    
    // MARK: - Public func
    
    func loadUrl() {
        var updatedPath = self.urlString
        // Check if we have a saved path
        if let savedPath {
            if savedPath.canBeUsed() {
                // Add saved path to main url
                updatedPath += savedPath.path
            }
            // Remove from userdefaults once its being used
            self.userDefaultHelper.removeObject(forKey: .userAlternatorPath)
        }
        
        debugPrint("[Bonnet Alternator] URL: \(updatedPath)")
        
        guard let url = URL(string: updatedPath) else { return }
        
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: url))
            self.webService.addListeners(self)
        }
    }
    
    // MARK: - Test environment
    
    func openBrowser() {
        self.didReceive(.init(type: .browser, platform: .ios, data: .init(value: "https://www.google.co.uk/")))
    }
    
    func requestJSToken() {
        Task {
            do {
                guard let token = try await self.webService.tokenDelegate?.refreshToken() else {
                    debugPrint("[Bonnet Alternator] TokenGeneratorDelegate haven't been assign")
                    return
                }
                debugPrint("[Bonnet Alternator] Token generated for test: \(token)")
                await self.updateToast(with: .init(style: .warning, message: "Generated token: \(token)", duration: 3, position: .bottom))
                
            } catch let error {
                debugPrint("[Bonnet Alternator] Token could not be generated, error: \(error.message)")
            }
        }
    }
    
    // MARK: - Messaging toast
    // Only used for testing
    
    @MainActor
    private func updateToast(with toast: Toast) {
        guard self.environment == .staging else { return }
        self.toast = toast
    }
    
    // MARK: - Communication
    
    @MainActor
    private func updateLocation(with coordinates: Coordinate) async {
        do {
            let content = try CommomResponseModel(type: .userLocation, data: .init(key: nil, jwt: nil, value: nil, latitude: coordinates.latitude, longitude: coordinates.longitude)).toString()
            self.webService.post(content, includeFormat: false, encrypted: true)
            debugPrint("[Bonnet Alternator] Coordinates updated")
        } catch let error {
            debugPrint("[Bonnet Alternator] Couldn't update coordinates, with error: \(error.message)")
        }
    }
}

// MARK: - Message Handler

extension AlternatorViewModel: MessageHandler {
    func didReceive(_ response: CommomResponseModel) {
        guard let message = response.data?.value else { return }
        
        if response.type == .browser {
            guard let url = URL(string: message), UIApplication.shared.canOpenURL(url) else { return }
            
            debugPrint("[Bonnet Alternator] Did receive url: \(message)")
            
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
            return
        }
        
        if response.type == .intercom,
           let isIntercomOpen = response.data?.setting
        {
            // Intercom have their own listener to update the view, so the keyboard changes should not happen when the keyboard its open from Intercom
            self.isIntercomOpen = isIntercomOpen
            DispatchQueue.main.async {
                self.allowKeyboardChanges = !isIntercomOpen
            }
            return
        }
        
        if response.type == .path,
           let path = self.savedPath?.path
        {
            // Dont use keyboard changes if we are on location details (search)
            let isLocationDetails = path.contains("/locations/")
            DispatchQueue.main.async {
                self.allowKeyboardChanges = !isLocationDetails
            }
        }
        
        debugPrint("[Bonnet Alternator] Did receive message: \(message)")
    }
    
    @MainActor
    func updateLoader(_ loading: Bool) {
        self.isLoading = loading
    }
    
    func error(_ message: String) {
        debugPrint("[Bonnet Alternator] Did receive error: \(message)")
    }
}
#endif
