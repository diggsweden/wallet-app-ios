import SwiftUI

struct SettingsView: View {
  let onLogout: () async -> Void
  @Environment(Router.self) private var router

  var body: some View {
    VStack(spacing: 24) {
      Image(.diggLogo)
      Text("App version: \(Bundle.main.appVersion) (\(Bundle.main.buildNumber))")
      Spacer()
      PrimaryButton("Logga ut") {
        Task {
          await onLogout()
        }
        router.pop()
      }
    }
  }
}

#Preview {
  SettingsView {}
}
