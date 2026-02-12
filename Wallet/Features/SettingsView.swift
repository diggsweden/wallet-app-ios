// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct SettingsView: View {
  let onLogout: () async -> Void
  @Environment(Router.self) private var router

  var body: some View {
    VStack(spacing: 24) {
      Image(.diggLogo)
        .resizable()
        .scaledToFit()
        .frame(height: 200)
      Text("App version:")
        .textStyle(.h3)
      Text("\(Bundle.main.appVersion) (\(Bundle.main.buildNumber))")
        .textStyle(.bodyLarge)
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
