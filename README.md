# BonnetAlternator

Bonnet’s Alternator SDK can be added to iOS apps as a package that provides the best public EV charging experience with minimal setup. We provide a customisable Charging UI which allows your users to discover and access over 200,000 charge points across Europe.

# Getting Started

## Intallation

Minimum OS version required -> **iOS 14**

### Swift Package

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding Bonnet Alternator as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/bonnet-electric/BonnetAlternatoriOS.git", branch: "main")
],
```

Or add the dependency from Xcode Project/Package Dependencies, using the URL below, pointing to `main` branch.

```swift
https://github.com/bonnet-electric/BonnetAlternatoriOS.git
```

### Cocoa Pods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Bonnet Alternator into your Xcode project using CocoaPods, specify it in your `Podfile`:

```swift
pod 'BonnetAlternator', :git => 'https://github.com/bonnet-electric/BonnetAlternatoriOS.git', :branch => 'main'
```

## Usage

Start by importing the SDK in the file you want to present it from by simply calling:

```swift
import BonnetAlternator
```

This will then allow you to present the ChargingUI using the framework of your choice, UIKit or SwiftUI, as is demonstrated below. In both cases, the ChargingUI takes in a `logoImage` and `tokenDelegate` as arguments, which are your company’s logo which appears on the top left of the ChargingUI, and the Delegate which retrieves your user’s auth token from your server, respectively.

**LogoIcon**
The `logoImage` is type `LogoIcon`, as shown below the initialisation receive the name of the image and the size, where the size defines the width of the image being `narrow` (default) or `wide`.

```swift
// Initialisation example
LogoIcon(name: <#T##String#>, size: <#T##Size#>)

// Options for Size enum
enum Size {
    /// Icon sized 34x24
    case narrow
    /// Icon sized 110x24
    case wide
}
```

### Environment
Before presenting the ChargingUI assign the correct environment that Alternator should run in, either `staging` (test) or `production`.

```swift
BonnetAlternator.setEnvironment(to: <#T##AlternatorEnvironment#>)
```
*Recommendations:*
- If the ChargingUI will be presented from the same place all the time, add it into your `ViewDidLoad` for UIKit or in the initialisation of your `View` for SwiftUI.
- If the ChargingUI will be opened from different places, assign the environment at the start of your app, for example: 
    - In the initialisation of your `WindowGroup`, your main View.
    - **SceneDelegate** inside `func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)`
    - **AppDelegate** inside `func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool`

### UIKit
If you’re using the UIKit framework, it’s useful to note that the ChargingUI is written in SwiftUI, which means that that the view will be wrapped in a `UIHostingController` before being presented.

```swift
BonnetAlternator().presentChargingUI(from: <#T##UIViewController#>, logoImage: <#T##LogoIcon?#>, tokenDelegate: <#T##TokenGeneratorDelegate?#>)
```

**Example**
```swift
class ViewController: UIViewController {
    
    @IBOutlet var alternatorButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func alternatorButtonTapped(_ sender: Any) {
        // Present the alternator view
        BonnetAlternator().presentChargingUI(from: self, tokenDelegate: self)
    }
}
```

### SwiftUI
When using SwiftUI, the presentation is done through a modifier, which means that the ChargingUI can simply be added to your view and the presentation state can be controlled with a `@State<Bool> / @Binding<Bool>` variable.

```swift
.showChargingUI(<#T##presented: Binding<Bool>##Binding<Bool>#>, logoImageName: <#T##String?#>, tokenDelegate: <#T##TokenGeneratorDelegate?#>)
```

**Example**
```swift
struct ContentView: View {
    
    @State private var showAlternator: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Button("Present Bonnet Alternator") {
                self.showAlternator = true
            }
        }
        .padding()
        .showBonnetAlternator($showAlternator, logoImage: .init(name: "bonnet.logo"), tokenDelegate: nil)
    }
}
```

### Token Generation/Refresh

To use this SDK, your users will need an authentication token that will need to be generated in your server, and passed onto the SDK so it can securely be passed on to Bonnet’s server see [Authentication/authorisation](https://www.notion.so/Authentication-authorisation-6a391f45fffc46e9a09dff6f8e683b85?pvs=21). For this, you will need a `TokenGeneratorDelegate`.
This delegate needs to be assigned during the presentation of the ChargingUI (See initialisation code examples above).
Add the delegate as an extension of your view and include the functions required to retrieve the token from your server.

**Example**
```swift
extension MyView: TokenGeneratorDelegate {
    func refreshToken() async throws -> String {
        let token = // Do the call to your server to obtain the Token
        return token
    }
}
```
