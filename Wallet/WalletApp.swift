import SwiftData
import SwiftUI
import WalletMacrosClient

@main
struct WalletApp: App {
  let clientGateway = GatewayClient()
  let sessionStore: SessionStore = {
    do {
      return try SessionStore()
    } catch {
      fatalError("Failed setting up storage")
    }
  }()

  var body: some Scene {
    WindowGroup {
      AppRootView(sessionStore: sessionStore)
        .themed
        .withOrientation
        .withToast
        .environment(\.gatewayClient, clientGateway)
    }
  }
}
