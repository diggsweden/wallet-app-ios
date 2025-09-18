import SwiftData
import SwiftUI

@main
struct WalletApp: App {
  var body: some Scene {
    WindowGroup {
      RootView()
        .modelContainer(for: [User.self, Wallet.self])
    }
  }
}

struct RootView: View {
  @Query private var users: [User]
  @Query private var wallets: [Wallet]
  private var isEnrolled: Bool {
    return users.first != nil && wallets.first != nil
  }

  var body: some View {
    Group {
      if !isEnrolled {
        EnrollmentRootView()
      } else {
        AppRootView()
      }
    }
    .animation(.easeInOut, value: isEnrolled)
  }
}
