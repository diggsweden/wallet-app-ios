// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import WalletDemo

@MainActor
@Suite("ExpandErrorView snapshots", .snapshots(record: .missing))
struct ExpandErrorViewSnapshotTests {
  @Test("Expand — code + time")
  func codeAndTime() {
    assertThemedSnapshots(
      of: ExpandErrorView(code: "SERVER_ERROR_500", time: "14:32:03"),
      width: 360
    )
  }
}
