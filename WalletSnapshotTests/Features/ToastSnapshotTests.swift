// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import WalletDemo

@MainActor
@Suite("Toast snapshots", .snapshots(record: .missing))
struct ToastSnapshotTests {
  @Test("Toast — info")
  func info() {
    assertThemedSnapshots(
      of: ToastView(Toast(type: .info, title: "Lite information")) {},
      width: 350,
    )
  }

  @Test("Toast — success")
  func success() {
    assertThemedSnapshots(
      of: ToastView(Toast(type: .success, title: "Något gick bra!")) {},
      width: 350,
    )
  }

  @Test("Toast — warning")
  func warning() {
    assertThemedSnapshots(
      of: ToastView(Toast(type: .warning, title: "En varning!")) {},
      width: 350,
    )
  }

  @Test("Toast — error")
  func error() {
    assertThemedSnapshots(
      of: ToastView(Toast(type: .error, title: "Något gick fel! Testa igen")) {},
      width: 350,
    )
  }
}
