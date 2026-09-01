// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import WalletMacros

@MainActor
@Observable
final class SettingsViewModel {
  private let onLogout: () async throws -> Void
  var hadLogoutError: Bool = false

  let helpUrl = #URL("https://diggsweden.github.io/wallet-utvecklarportal/")

  var feedbackMailUrl: URL? {
    let info = SystemInfoProvider.shared.snapshot()
    var components = URLComponents()
    components.scheme = "mailto"
    components.path = "digitalwallet@digg.se"
    components.queryItems = [
      URLQueryItem(name: "subject", value: "Feedback till ID-plånboken"),
      URLQueryItem(
        name: "body",
        value: "\n\n---\nOS: iOS"
          + "\nApp version: \(info.appVersion)"
          + "\nDevice: \(info.deviceModel)"
          + "\nOS Version: \(info.iosVersion)"
          + "\nNetwork: \(info.network)",
      ),
    ]
    return components.url
  }

  init(onLogout: @escaping () async throws -> Void) {
    self.onLogout = onLogout
  }

  @MainActor
  func logout() async -> Bool {
    hadLogoutError = false

    do {
      try await onLogout()
      return true
    } catch {
      hadLogoutError = true
      return false
    }
  }
}
