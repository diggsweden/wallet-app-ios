import SwiftData
import SwiftUI

@main
struct WalletApp: App {
  var body: some Scene {
    WindowGroup {
      AppRootView()
        .modelContainer(for: AppSession.self)
    }
  }
}
