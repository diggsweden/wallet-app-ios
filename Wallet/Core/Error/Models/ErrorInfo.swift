// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct ErrorInfo: Sendable {
  let code: String?
  let message: String?
  let endpoint: String?
  let traceId: String?
  let appVersion: String?
  let timestamp: String?
  let iosVersion: String?
  let deviceModel: String?
  let network: String?

  init(
    code: String? = nil,
    message: String? = nil,
    endpoint: String? = nil,
    traceId: String? = nil,
    appVersion: String? = nil,
    timestamp: String? = nil,
    iosVersion: String? = nil,
    deviceModel: String? = nil,
    network: String? = nil
  ) {
    self.code = code
    self.message = message
    self.endpoint = endpoint
    self.traceId = traceId
    self.appVersion = appVersion
    self.timestamp = timestamp
    self.iosVersion = iosVersion
    self.deviceModel = deviceModel
    self.network = network
  }
}

extension ErrorInfo {
  static let mock = ErrorInfo(
    code: "SERVER_ERROR_500",
    message: "Kunde inte hämta innehåll från servern",
    endpoint: "POST /v0/accounts",
    traceId: "abcdefgh-digg-38sdgj5-DFJSFJSJDF",
    appVersion: "0.98",
    timestamp: "14:32:03",
    iosVersion: "26.5",
    deviceModel: "iPhone 15",
    network: "Wi-Fi"
  )
}
