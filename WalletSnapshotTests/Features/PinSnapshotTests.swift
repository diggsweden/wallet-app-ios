// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import WalletDemo

@MainActor
@Suite("Pin snapshots", .snapshots(record: .missing))
struct PinSnapshotTests {
  @Test("Pin entry")
  func pinEntry() {
    assertThemedDeviceSnapshots(
      of: PinView { _ in }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .withOrientation
        .withToast
    )
  }
}
