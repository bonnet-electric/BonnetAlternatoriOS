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
    
    /// Should be call whent he users log in to preload their information
    /// - Parameter tokenGeneratorDelegate: Token generator protocol
    public func getUserProfile(tokenGeneratorDelegate: TokenGeneratorDelegate?) async throws {
        guard let token = try await tokenGeneratorDelegate?.refreshToken() else {
            debugPrint("[Alternator] We were unable to retrieve a token. Please check the TokenGeneratorDelegate functions are set properly!")
            throw SecurityServiceError.other(message: "Something went wrong. Please try again later")
        }
        
        let userProfile = try await HTTPNetworkClient.shared.preloadUserProfile(with: token, for: self.activeEnvironment)
        UsersDefaultHelper.shared.save(userProfile, withKey: .userProfile)
        debugPrint("[Alternator] User profile saved succesfully!")
    }
    
    /// Should be called if the user log out
    public func clearUserProfile() {
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
