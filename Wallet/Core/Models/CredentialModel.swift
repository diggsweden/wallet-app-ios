// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenID4VCI
import SwiftData

struct Disclosure: Codable, Identifiable, Hashable, Sendable {
  let base64: String
  let displayName: String
  let value: String

  var id: String { base64 }
}

struct IssuerDisplay: Codable, Hashable, Sendable {
  let name: String
  let info: String?
  let imageUrl: URL?
}

struct Credential: Codable, Hashable, Sendable {
  let issuer: IssuerDisplay
  let sdJwt: String
  let disclosures: [String: Disclosure]
  var issuedAt: Date = .now
}
