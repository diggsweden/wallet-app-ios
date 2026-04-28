// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftData

enum SchemaV2: VersionedSchema {
  static var models: [any PersistentModel.Type] {
    [User.self]
  }

  static let versionIdentifier = Schema.Version(2, 0, 0)
}

extension SchemaV2 {
  @Model
  final class User {
    @Attribute(.unique) var id = 0
    var accountId: String?
    var credentials: [SavedCredential]
    var pid: SavedCredential?

    init(
      id: Int = 0,
      accountId: String? = nil,
      credentials: [SavedCredential] = [],
      pid: SavedCredential? = nil
    ) {
      self.id = id
      self.accountId = accountId
      self.credentials = credentials
      self.pid = pid
    }
  }
}

extension SchemaV2 {
  enum CredentialType: String, Codable, Sendable {
    case pid = "urn:eudi:pid:1"
  }

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
}
