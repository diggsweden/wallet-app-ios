// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SnapshotTesting
import SwiftUI
import Testing

@testable import WalletDemo

@MainActor
@Suite("PinDot snapshots", .snapshots(record: .missing))
struct PinDotSnapshotTests {
  private static let strategy = Snapshotting<PinDot, UIImage>
    .image(
      precision: 1,
      perceptualPrecision: 0.98,
      layout: .fixed(width: 48, height: 48),
    )

  @Test("Filled dot")
  func filled() {
    assertSnapshot(
      of: PinDot(filled: true, color: .black, size: 24),
      as: Self.strategy,
    )
  }

  @Test("Empty dot")
  func empty() {
    assertSnapshot(
      of: PinDot(filled: false, color: .black, size: 24),
      as: Self.strategy,
    )
  }
}
