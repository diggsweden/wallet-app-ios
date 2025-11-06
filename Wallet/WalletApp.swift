import SwiftData
import SwiftUI
import WalletMacrosClient

@main
struct WalletApp: App {
  let clientGateway = GatewayClient()
  let userStore: UserStore = {
    do {
      return try UserStore()
    } catch {
      fatalError("Failed setting up storage")
    }
  }()

  var body: some Scene {
    WindowGroup {
      AppRootView(userStore: userStore)
        .themed
        .withOrientation
        .withToast
        .environment(\.gatewayClient, clientGateway)
    }
  }
}
