// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public extension Data {
  private static let pemHeader = "-----BEGIN CERTIFICATE-----"
  private static let pemFooter = "-----END CERTIFICATE-----"

  init?(encodedCertificate: String) {
    let value = encodedCertificate.trimmingCharacters(in: .whitespacesAndNewlines)

    guard value.hasPrefix(Self.pemHeader) else {
      self.init(base64UrlEncoded: value)
      return
    }

    let body =
      value
      .replacingOccurrences(of: Self.pemHeader, with: "")
      .replacingOccurrences(of: Self.pemFooter, with: "")

    self.init(base64Encoded: body, options: .ignoreUnknownCharacters)
  }
}
