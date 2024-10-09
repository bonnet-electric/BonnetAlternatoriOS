import SwiftUI
import BFSecurity

public typealias Completion = (() -> Void)?

public struct BonnetAlternator {
    public init() { }
    
    // MARK: - Environment
    
    /// Assign environment
    public static func setEnvironment(to newEnvironment: AlternatorEnvironment) {
        UsersDefaultHelper.shared.save(newEnvironment.rawValue, withKey: .environment)
        debugPrint("[Alternator] Environment mode set to: \(newEnvironment.rawValue)")
    }
    
    /// Get active environment
    public var activeEnvironment: AlternatorEnvironment {
        guard let envString = UsersDefaultHelper.shared.getString(forKey: .environment),
              let environment = AlternatorEnvironment(rawValue: envString)
        else { return .production }
        return environment
    }
    
    // MARK: - Profile
    /// Will request the users profile data, if succesful will save it in UserDefaults (Cache).
    /// - Important: Should be called everytime a user Sign In
    /// - Parameter tokenGeneratorDelegate: Token generator protocol
    public func getUserData(with delegate: TokenGeneratorDelegate?) async throws {
        guard let token = try await delegate?.refreshToken() else {
            debugPrint("[Alternator] We were unable to retrieve a token. Please check the TokenGeneratorDelegate functions are set properly!")
            throw SecurityServiceError.other(message: "Something went wrong. Please try again later")
        }
        
        let userProfile = try await HTTPNetworkClient.shared.preloadUserProfile(with: token, for: self.activeEnvironment)
        UsersDefaultHelper.shared.save(userProfile, withKey: .userProfile)
        debugPrint("[Alternator] User profile saved succesfully!")
    }
    
    /// Verify if user profile is saved in cache
    public var isUserDataCached: Bool {
        guard let profile = UsersDefaultHelper.shared.getString(forKey: .userProfile), !profile.isEmpty else { return false }
        return true
    }
    
    /// Will clear the user's profile data from UserDefaults (Cache)
    /// - Important: Should be called everytime the user Sign Out
    public func clearUserData() {
        UsersDefaultHelper.shared.removeObject(forKey: .userProfile)
        debugPrint("[Alternator] User profile removed succesfully!")
    }
    
    // MARK: - UIKit Presentation
    
    #if canImport(UIKit)
    /// Present Bonnet charging screen
    /// - Parameters:
    ///   - controller: Parent from where the view will be presented
    ///   - logoImage: Logo name and style [Square or Rectangular] (Optional)
    ///   - tokenDelegate: Token generation delegate.
    public func presentChargingUI(from controller: UIViewController,
                                  logoImage: LogoIcon? = nil,
                                  tokenDelegate: TokenGeneratorDelegate?
    ) {
        let view = AlternatorView(viewModel: .init(tokenDelegate: tokenDelegate),
                                  parentController: controller,
                                  logoImage: logoImage)
        let hosting = UIHostingController(rootView: view)
        hosting.modalPresentationStyle = .fullScreen
        hosting.modalTransitionStyle = .coverVertical
        controller.present(hosting, animated: true)
    }
    #endif
}

#if os(iOS)
extension View {
    public func showChargingUI(_ presented: Binding<Bool>,
                               logoImage: LogoIcon? = nil,
                               delegate: TokenGeneratorDelegate?) -> some View 
    {
        let viewModel = AlternatorViewModel(tokenDelegate: delegate)
        return self.modifier(AlternatorViewModifier(isPresented: presented, viewModel: viewModel, logoImage: logoImage))
    }
}
#endif
