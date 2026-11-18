// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import UIComponents
@testable import WalletDemo

@MainActor
@Suite("Pin keypad snapshots", .snapshots(record: .missing))
struct PinKeypadSnapshotTests {
  @Test("Keypad — delete enabled")
  func deleteEnabled() {
    assertThemedSnapshots(
      of: Self.keypad(isDeleteEnabled: true, isSubmitEnabled: false),
      width: 320,
    )
  }

  @Test("Keypad — delete disabled")
  func deleteDisabled() {
    assertThemedSnapshots(
      of: Self.keypad(isDeleteEnabled: false, isSubmitEnabled: false),
      width: 320,
    )
  }

  @Test("Keypad — submit enabled")
  func submitEnabled() {
    assertThemedSnapshots(
      of: Self.keypad(isDeleteEnabled: true, isSubmitEnabled: true),
      width: 320,
    )
  }

  private static func keypad(isDeleteEnabled: Bool, isSubmitEnabled: Bool) -> PinKeypadView {
    PinKeypadView(
      submitLabel: "Nästa",
      isDeleteEnabled: isDeleteEnabled,
      isSubmitEnabled: isSubmitEnabled,
      onTapDigit: { _ in },
      onTapDelete: {},
      onTapSubmit: {},
    )
  }
}
