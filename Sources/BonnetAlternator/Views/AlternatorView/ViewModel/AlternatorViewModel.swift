//
//  AlternatorViewModel.swift
//  
//
//  Created by Ana Márquez on 20/06/2023.
//

#if os(iOS)
import WebKit
import SwiftUI
import Combine
import CoreLocation

class AlternatorViewModel: NSObject, ObservableObject {
    // MARK: - Published
    @Published var toast: Toast? = nil
    @Published var isLoading: Bool = true
    @Published var allowKeyboardChanges: Bool = true
    
    // MARK: - Parameters
    let webView: WKWebView
    let environment: AlternatorEnvironment
    
    private var webViewLoaded: Bool = false
    private var enterBackground: Bool = false
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
        
        self.userLocationService = UserLocationService.shared
        
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
        debugPrint("[Bonnet Alternator] [VM] Deinit")
        self.cancellables.removeAll()
    }
    
    private func addListeners() {
        // Listen to the successful connection confirmation
        self.webService.connectionCompleted = { [weak self] in
            guard let self else { return }
            Task {
                await MainActor.run(body: {
                    self.webViewLoaded = true
                    
                    if self.userLocationService.authorizationStatus.permissionForLocationTrackingGranted,
                       let coordinate = self.userLocationService.currentCoordinate
                    {
                        Task { await self.updateLocation(with: coordinate) }
                    } else {
                        self.userLocationService.askUserPermissionForWhenInUseAuthorizationIfNeeded()
                    }
                })
            }
        }
        
        // Listen to user's current location
        self.userLocationService.$currentCoordinate.receive(on: DispatchQueue.main).sink { [weak self] newValue in
            guard let self, let coordinate = newValue, self.webViewLoaded else { return }
            Task { await self.updateLocation(with: coordinate) }
        }.store(in: &cancellables)
        
        // Check if permissions have changed during communication
        self.userLocationService.$authorizationStatus.receive(on: DispatchQueue.main).sink { [weak self] newValue in
            guard let self, let userCoordinates = self.userLocationService.currentCoordinate else { return }
            Task { await self.updateLocation(with: userCoordinates) }
        }.store(in: &cancellables)
        
        // MARK: - App cycle
        let backgroundDateKey = "AppEnterBackgroundDate"
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification, object: nil).sink { _ in
            guard self.enterBackground else { return }
            
            // Check the time when the app enter in background, if is more that 60 sec, them we will load the entire web view again, if not we will just re-add the listeners to the webservice.
            if let backgroundDate = UserDefaults.standard.object(forKey: backgroundDateKey),
               let date = backgroundDate as? Date
            {
                let timeDistanceInSec = date.timeIntervalSince(Date())
                
                if timeDistanceInSec < 60 {
                    self.webService.addListeners(self)
                    return
                }
            }
            
            self.enterBackground = false
            Task { await self.loadUrl() }
        }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification, object: nil).sink { _ in
            self.enterBackground = true
            UserDefaults.standard.set(Date(), forKey: backgroundDateKey)
            self.pauseStopProcess()
        }.store(in: &cancellables)
    }
    
    // MARK: - Lifecycle
    
    func pauseStopProcess() {
        self.webView.stopLoading()
        self.webService.removeListeners()
    }
}

extension AlternatorViewModel {
    
    // MARK: - Variables
    internal var savedPath: SavedPath? {
        self.userDefaultHelper.get(forKey: .userAlternatorPath)
    }
    
    // MARK: - Public func
    
    @MainActor
    func loadUrl() async {
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
        
        guard let url = URL(string: updatedPath) else { return }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        if self.webViewLoaded {
            // Clean cache to allow the webview to initialise the request from the begging
            await WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date(timeIntervalSince1970: 0))
        }
        self.webView.load(request)
        self.webService.addListeners(self)
    }
    
    func startUpdatingUserLocation() {
        if self.userLocationService.authorizationStatus.permissionForLocationTrackingGranted {
            self.userLocationService.startUpdatingLocation()
        }
        
        // If the communication have been already established we need to update the user location if available
        if self.webViewLoaded, let coordinate = self.userLocationService.currentCoordinate {
            Task { await self.updateLocation(with: coordinate) }
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
    private func updateLocation(with coordinate: CLLocationCoordinate2D) async {
        guard self.webViewLoaded else { return }
        
        do {
            let content = try CommomResponseModel.userLocation(with: coordinate).toString()
            self.webService.post(content, includeFormat: false, encrypted: true)
            debugPrint("[Bonnet Alternator] Coordinate updated")
        } catch let error {
            debugPrint("[Bonnet Alternator] Couldn't update coordinate, error: \(error.localizedDescription)")
        }
    }
}
#endif
