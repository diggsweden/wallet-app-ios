// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct IssuerDisplay: Codable, Hashable, Sendable {
  let name: String
  let info: String?
  let imageUrl: URL?
}

struct SavedCredential: Codable, Hashable, Sendable {
  let issuer: IssuerDisplay
  let compactSerialized: String
  let claimDisplayNames: [String: String]
  let claimsCount: Int
  var issuedAt: Date = .now
}
