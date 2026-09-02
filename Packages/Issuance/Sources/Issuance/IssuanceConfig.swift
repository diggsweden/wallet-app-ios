// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public struct IssuanceConfig: Sendable {
  public let clientId: String
  public let redirectUri: URL

  public init(clientId: String, redirectUri: URL) {
    self.clientId = clientId
    self.redirectUri = redirectUri
  }
}
