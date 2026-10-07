// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum ScanEvent: Sendable {
  case scanned(String)
  case unavailable
}

@MainActor
protocol CodeScanner: AnyObject {
  func start() throws -> AsyncStream<ScanEvent>
  func stop()
}
