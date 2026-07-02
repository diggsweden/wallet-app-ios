// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import WalletDemo

@MainActor
@Suite("T9 keypad snapshots", .snapshots(record: .missing))
struct T9KeypadSnapshotTests {
  @Test("Keypad — clear enabled")
  func clearEnabled() {
    assertThemedSnapshots(
      of: T9KeypadView(onTapDigit: { _ in }, clearButtonDisabled: false, onClear: {}),
      width: 320
    )
  }

  @Test("Keypad — clear disabled")
  func clearDisabled() {
    assertThemedSnapshots(
      of: T9KeypadView(onTapDigit: { _ in }, clearButtonDisabled: true, onClear: {}),
      width: 320
    )
  }
}
