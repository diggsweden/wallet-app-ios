// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI

struct SettingsView: View {
  @Environment(Router.self) private var router
  @Environment(\.openURL) private var openURL
  @Environment(\.theme) private var theme
  @State private var settingsViewModel: SettingsViewModel
  @State private var isLogoutConfirmationPresented = false

  init(onLogout: @escaping () async throws -> Void) {
    self._settingsViewModel = State(
      wrappedValue: SettingsViewModel(onLogout: onLogout)
    )
  }

  var body: some View {
    NavigationStack {
      List {
        appInfoSection
        accountDetailsSection
      }
      .navigationTitle("Inställningar")
      .navigationBarTitleDisplayMode(.inline)
      .alert("Logga ut?", isPresented: $isLogoutConfirmationPresented) {
        Button("Logga ut", role: .destructive) { onLogoutTap() }
        Button("Avbryt", role: .cancel) {}
      } message: {
        Text(
          "All din data raderas från den här enheten, inklusive dina dokument. "
            + "Detta går inte att ångra."
        )
      }
      .alert("Kunde inte logga ut", isPresented: $settingsViewModel.hadLogoutError) {
        Button("Försök igen") { onLogoutTap() }
        Button("Avbryt", role: .cancel) {}
      }
    }
  }
}

private extension SettingsView {
  var appInfoSection: some View {
    Section {
      linkRow("Skicka feedback", systemImage: "envelope") {
        if let url = settingsViewModel.feedbackMailUrl {
          openURL(url)
        }
      }
      linkRow("Hjälp", systemImage: "questionmark.circle") {
        openURL(settingsViewModel.helpUrl)
      }
      NavigationLink {
        AboutView()
      } label: {
        rowLabel("Om appen", systemImage: "info.circle")
      }
    }
  }

  var accountDetailsSection: some View {
    Section {
      Button(role: .destructive) {
        isLogoutConfirmationPresented = true
      } label: {
        Label {
          Text("Logga ut")
            .textStyle(.body)
        } icon: {
          Image(systemName: "rectangle.portrait.and.arrow.right")
        }
        .foregroundStyle(theme.colors.errorInverse)
      }
    }
  }

  func linkRow(
    _ title: String,
    systemImage: String,
    action: @escaping () -> Void,
  ) -> some View {
    Button(action: action) {
      HStack {
        rowLabel(title, systemImage: systemImage)
        Spacer()
        Image(systemName: "arrow.up.right")
          .font(.footnote)
          .foregroundStyle(.secondary)
          .accessibilityHidden(true)
      }
    }
  }

  func rowLabel(_ title: String, systemImage: String) -> some View {
    Label {
      Text(title)
        .textStyle(.body)
        .foregroundStyle(theme.colors.textPrimary)
    } icon: {
      Image(systemName: systemImage)
        .foregroundStyle(theme.colors.linkPrimary)
    }
  }

  func onLogoutTap() {
    Task {
      let didLogout = await settingsViewModel.logout()

      if didLogout { router.reset() }
    }
  }
}

#Preview {
  SettingsView {}
    .environment(Router())
    .themed
}
