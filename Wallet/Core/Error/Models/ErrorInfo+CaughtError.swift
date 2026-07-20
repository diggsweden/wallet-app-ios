// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

extension ErrorInfo {
  init(from caught: CaughtError, system: SystemInfo) {
    self.init(
      code: caught.code,
      message: caught.message,
      endpoint: caught.endpoint,
      traceId: caught.traceId,
      appVersion: system.appVersion,
      timestamp: Self.timeFormatter.string(from: caught.occurredAt),
      iosVersion: system.iosVersion,
      deviceModel: system.deviceModel,
      network: system.network
    )
  }

  static let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
  }()
}
