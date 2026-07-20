// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI
import Testing

@testable import WalletDemo

@MainActor
@Suite("Control snapshots", .snapshots(record: .missing))
struct ControlSnapshotTests {
  @Test("Checkbox — checked")
  func checkboxChecked() {
    assertThemedSnapshots(of: Checkbox(isOn: .constant(true)))
  }

  @Test("Checkbox — unchecked")
  func checkboxUnchecked() {
    assertThemedSnapshots(of: Checkbox(isOn: .constant(false)))
  }

  @Test("Selective disclosure — selected")
  func selectiveDisclosureSelected() {
    assertThemedSnapshots(
      of: SelectiveDisclosureView(isSelected: .constant(true), claims: Self.claims)
    )
  }

  @Test("Selective disclosure — unselected")
  func selectiveDisclosureUnselected() {
    assertThemedSnapshots(
      of: SelectiveDisclosureView(isSelected: .constant(false), claims: Self.claims)
    )
  }

  private static let claims: [ClaimUiModel] = [
    ClaimUiModel(id: "birth_date", displayName: "Födelsedatum", value: .string("1955-04-12")),
    ClaimUiModel(id: "age", displayName: "Ålder", value: .int(70)),
  ]
}
