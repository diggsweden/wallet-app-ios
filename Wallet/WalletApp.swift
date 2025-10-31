import SwiftData
import SwiftUI
import WalletMacrosClient

@main
struct WalletApp: App {
  let clientGateway = GatewayClient()

  var body: some Scene {
    WindowGroup {
      AppRootView()
        .modelContainer(for: AppSession.self)
        .environment(\.gatewayClient, clientGateway)
    }
  }
}
