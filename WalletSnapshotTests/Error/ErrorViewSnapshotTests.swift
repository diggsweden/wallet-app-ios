// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import WalletDemo

@MainActor
@Suite("ErrorView snapshots", .snapshots(record: .missing))
struct ErrorViewSnapshotTests {
  @Test("Error — primary + link")
  func primaryAndLink() {
    let model = ErrorView.ViewModel(
      primaryButton: .init(label: "Försök igen", accessibilityHint: "Försök igen", action: {}),
      linkButton: .init(label: "Få hjälp", accessibilityHint: "Få hjälp", action: {}),
    )
    assertThemedDeviceSnapshots(of: ErrorView(model: model).defaultScreenStyle)
  }

  @Test("Error — two buttons + link")
  func twoButtonsAndLink() {
    let model = ErrorView.ViewModel(
      primaryButton: .init(label: "Försök igen", accessibilityHint: "Försök igen", action: {}),
      secondaryButton: .init(label: "Avbryt", accessibilityHint: "Avbryt", action: {}),
      linkButton: .init(label: "Få hjälp", accessibilityHint: "Få hjälp", action: {}),
    )
    assertThemedDeviceSnapshots(of: ErrorView(model: model).defaultScreenStyle)
  }
}
