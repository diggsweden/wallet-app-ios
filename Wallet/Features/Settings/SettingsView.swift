// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI

struct SettingsView: View {
  @Environment(Router.self) private var router
  @State private var settingsViewModel: SettingsViewModel

  init(onLogout: @escaping () async throws -> Void) {
    self._settingsViewModel = State(
      wrappedValue: SettingsViewModel(onLogout: onLogout)
    )
  }

  var body: some View {
    VStack(spacing: 24) {
      Image(.diggLogo)
        .resizable()
        .scaledToFit()
        .frame(height: 200)
        .accessibilityHidden(true)
      Text("App version:")
        .textStyle(.h3)
      Text(Bundle.main.fullVersion)
        .textStyle(.bodyLarge)
      Spacer()
      PrimaryButton("Logga ut") {
        onLogoutTap()
      }
    }
    .alert("Kunde inte logga ut", isPresented: $settingsViewModel.hadLogoutError) {
      Button("Försök igen") { onLogoutTap() }
      Button("Avbryt", role: .cancel) {}
    }
  }
}

private extension SettingsView {
  func onLogoutTap() {
    Task {
      let didLogout = await settingsViewModel.logout()

      if didLogout {
        router.reset()
      }
    }
  }
}

#Preview {
  SettingsView {}
    .environment(Router())
}
