// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import WalletDemo

@MainActor
@Suite("Settings snapshots", .snapshots(record: .missing))
struct SettingsSnapshotTests {
  @Test("Settings")
  func settings() {
    assertThemedDeviceSnapshots(
      of: SettingsView {}.environment(Router())
    )
  }
}
