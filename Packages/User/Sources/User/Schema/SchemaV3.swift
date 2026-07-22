// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftData

enum SchemaV3: VersionedSchema {
  static var models: [any PersistentModel.Type] {
    [User.self]
  }

  static let versionIdentifier = Schema.Version(3, 0, 0)
}

extension SchemaV3 {
  @Model
  final class User {
    @Attribute(.unique) var id = 0
    var accountId: String?
    var credentials: [SavedCredential]
    var pid: SavedCredential?
    var hsmServerParameters: HsmServerParameters?

    init(
      id: Int = 0,
      accountId: String? = nil,
      credentials: [SavedCredential] = [],
      pid: SavedCredential? = nil,
      hsmServerParameters: HsmServerParameters? = nil,
    ) {
      self.id = id
      self.accountId = accountId
      self.credentials = credentials
      self.pid = pid
      self.hsmServerParameters = hsmServerParameters
    }
  }
}

extension SchemaV3 {
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
    let type: String
    let displayData: CredentialDisplayData?
  }

  struct CredentialDisplayData: Codable, Hashable, Sendable {
    let name: String?
  }

  struct HsmServerParameters: Codable, Hashable, Sendable {
    let serverJwsPublicKey: HsmServerJwk
    let opaqueContext: Data
    let opaqueServerIdentifier: Data
  }

  struct HsmServerJwk: Codable, Hashable, Sendable {
    let kty: String
    let crv: String
    let x: String
    let y: String
    let kid: String?
  }
}
