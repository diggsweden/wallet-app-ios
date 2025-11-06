import SwiftData
import SwiftUI
import WalletMacrosClient

@main
struct WalletApp: App {
  private let userStore: UserStore
  private let sessionManager: SessionManager
  private let gatewayAPIClient: GatewayAPIClient

  init() {
    do {
      userStore = try UserStore()
    } catch {
      fatalError("Failed setting up storage")
    }

    self.sessionManager = SessionManager(accountIDProvider: userStore)
    self.gatewayAPIClient = GatewayAPIClient(sessionManager: sessionManager)
  }

  var body: some Scene {
    WindowGroup {
      AppRootView(userStore: userStore)
        .themed
        .withOrientation
        .withToast
        .environment(\.gatewayAPIClient, gatewayAPIClient)
    }
  }
}
