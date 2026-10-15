// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import QRScanner

@MainActor
@Suite("ScannerInfo snapshots", .snapshots(record: .missing))
struct ScannerInfoSnapshotTests {
  @Test("Scanner info")
  func scannerInfo() {
    assertThemedDeviceSnapshots(of: ScannerInfoView())
  }
}
