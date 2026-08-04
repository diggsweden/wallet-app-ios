// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import WalletDemo

@MainActor
@Suite("Button snapshots", .snapshots(record: .missing))
struct ButtonSnapshotTests {
  @Test("Primary — default")
  func primaryDefault() {
    assertThemedSnapshots(of: PrimaryButton("Fortsätt", onClick: {}), width: 360)
  }

  @Test("Primary — with icon")
  func primaryWithIcon() {
    assertThemedSnapshots(
      of: PrimaryButton("Fortsätt", icon: "arrow.right", onClick: {}),
      width: 360,
    )
  }

  @Test("Primary — disabled")
  func primaryDisabled() {
    assertThemedSnapshots(of: PrimaryButton("Fortsätt", onClick: {}).disabled(true), width: 360)
  }

  @Test("Secondary — default")
  func secondaryDefault() {
    assertThemedSnapshots(of: SecondaryButton("Avbryt", onClick: {}), width: 360)
  }

  @Test("Secondary — with icon")
  func secondaryWithIcon() {
    assertThemedSnapshots(of: SecondaryButton("Avbryt", icon: "xmark", onClick: {}), width: 360)
  }

  @Test("Secondary — disabled")
  func secondaryDisabled() {
    assertThemedSnapshots(of: SecondaryButton("Avbryt", onClick: {}).disabled(true), width: 360)
  }
}
