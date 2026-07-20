// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import WalletDemo

@MainActor
@Suite("Presentation snapshots", .snapshots(record: .missing))
struct PresentationSnapshotTests {
  @Test("Pin — entry")
  func pinEntry() {
    assertThemedDeviceSnapshots(
      of: PresentationPinView(isLoading: false, onPinEntered: { _ in })
        .environment(ToastViewModel())
    )
  }

  @Test("Pin — loading")
  func pinLoading() {
    assertThemedDeviceSnapshots(
      of: PresentationPinView(isLoading: true, onPinEntered: { _ in })
        .environment(ToastViewModel())
    )
  }

  @Test("Success")
  func success() {
    assertThemedDeviceSnapshots(of: PresentationSuccessView(onDismiss: {}))
  }
}
