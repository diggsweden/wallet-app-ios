// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public struct SavedCredential: Codable, Hashable, Sendable {
  public let issuer: IssuerDisplay
  public let compactSerialized: String
  public let claimDisplayNames: [String: String]
  public let claimsCount: Int
  public let issuedAt: Date
  public let type: String
  public let displayData: CredentialDisplayData?

  public init(
    issuer: IssuerDisplay,
    compactSerialized: String,
    claimDisplayNames: [String: String],
    claimsCount: Int,
    issuedAt: Date,
    type: String,
    displayData: CredentialDisplayData?
  ) {
    self.issuer = issuer
    self.compactSerialized = compactSerialized
    self.claimDisplayNames = claimDisplayNames
    self.claimsCount = claimsCount
    self.issuedAt = issuedAt
    self.type = type
    self.displayData = displayData
  }
}

public struct IssuerDisplay: Codable, Hashable, Sendable {
  public let name: String
  public let info: String?
  public let imageUrl: URL?

  public init(name: String, info: String?, imageUrl: URL?) {
    self.name = name
    self.info = info
    self.imageUrl = imageUrl
  }
}

public struct CredentialDisplayData: Codable, Hashable, Sendable {
  public let name: String?

  public init(name: String?) {
    self.name = name
  }
}
