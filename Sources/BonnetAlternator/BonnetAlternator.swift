import SwiftUI

public typealias Completion = (() -> Void)?

public struct BonnetAlternator {
    public init() { }
    
    // MARK: - Environment
    
    /// Assign new active environment
    public static func setEnvironment(to newEnvironment: AlternatorEnvironment) {
        UsersDefaultHelper.shared.save(newEnvironment.rawValue, withKey: .environment)
        debugPrint("[Bonnet Alternator] Environment mode set to: \(newEnvironment.rawValue)")
    }
    
    /// Get active environment
    public var currentEnvironment: AlternatorEnvironment {
        guard let envString = UsersDefaultHelper.shared.getString(forKey: .environment),
              let environment = AlternatorEnvironment(rawValue: envString)
        else { return .production }
        return environment
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

// MARK: - Environment
public enum AlternatorEnvironment: String, Equatable {
    case staging, production
}
