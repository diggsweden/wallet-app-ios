// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import WalletDemo

@MainActor
@Suite("Welcome screen snapshots", .snapshots(record: .missing))
struct WelcomeScreenSnapshotTests {
  @Test("Welcome")
  func welcome() {
    assertThemedDeviceSnapshots(of: WelcomeScreen(onComplete: {}))
  }
}
