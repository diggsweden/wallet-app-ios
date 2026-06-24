// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

@MainActor
@Observable
final class SettingsViewModel {
  private let onLogout: () async throws -> Void
  var hadLogoutError: Bool = false

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
