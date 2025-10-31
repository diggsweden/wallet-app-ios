import SwiftUI

struct SettingsView: View {
  let onLogout: () -> Void

  var body: some View {
    VStack(spacing: 24) {
      Image(.diggLogo)
      Text("App version: \(Bundle.main.appVersion) (\(Bundle.main.buildNumber))")
      Spacer()
      PrimaryButton(label: "Logga ut", onClick: onLogout)
    }
  }
}

#Preview {
  SettingsView {}
}
