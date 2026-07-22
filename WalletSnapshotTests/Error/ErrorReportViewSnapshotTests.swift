// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import WalletDemo

@MainActor
@Suite("ErrorReportView snapshots", .snapshots(record: .missing))
struct ErrorReportViewSnapshotTests {
  @Test("Report — full")
  func full() {
    let info = ErrorInfo(
      code: "SERVER_ERROR_500",
      message: "Kunde inte hämta innehåll från servern",
      endpoint: "POST /v0/accounts",
      traceId: "abcdefgh-digg-38sdgj5-DFJSFJSJDF",
      appVersion: "0.98",
      timestamp: "14:32:03",
      iosVersion: "26.5",
      deviceModel: "iPhone 15",
      network: "Wi-Fi",
    )
    assertThemedDeviceSnapshots(of: ErrorReportView(info: info))
  }

  @Test("Report — device info only")
  func deviceInfoOnly() {
    let info = ErrorInfo(
      appVersion: "0.98",
      timestamp: "14:32:03",
      iosVersion: "26.5",
      deviceModel: "iPhone 15",
      network: "Wi-Fi",
    )
    assertThemedDeviceSnapshots(of: ErrorReportView(info: info))
  }
}
