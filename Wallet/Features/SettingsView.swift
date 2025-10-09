import SwiftUI

struct SettingsView: View {
  let onLogout: () -> Void
  @Environment(Router.self) private var router

  var body: some View {
    VStack(spacing: 24) {
      Image(.diggLogo)
      Text("App version: \(Bundle.main.appVersion) (\(Bundle.main.buildNumber))")
      Spacer()
      PrimaryButton(label: "Logga ut") {
        onLogout()
        router.pop()
      }
    }
  }
}

#Preview {
  SettingsView {}
}
