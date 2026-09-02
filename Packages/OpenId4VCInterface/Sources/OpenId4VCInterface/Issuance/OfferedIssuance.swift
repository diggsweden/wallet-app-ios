// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public struct OfferedIssuer: Sendable {
  public let name: String?
  public let info: String?
  public let imageUrl: URL?

  public init(name: String?, info: String?, imageUrl: URL?) {
    self.name = name
    self.info = info
    self.imageUrl = imageUrl
  }
}

public struct OfferedIssuance: Sendable {
  public let issuer: OfferedIssuer?
  public let claimDisplayNames: [String: String]

  public init(issuer: OfferedIssuer?, claimDisplayNames: [String: String]) {
    self.issuer = issuer
    self.claimDisplayNames = claimDisplayNames
  }
}
