// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftData

enum SchemaV1: VersionedSchema {
  static var models: [any PersistentModel.Type] {
    [User.self]
  }

  static let versionIdentifier = Schema.Version(1, 0, 0)
}

extension SchemaV1 {
  @Model
  final class User {
    @Attribute(.unique) var id = 0
    var deviceId: String = UUID().uuidString
    var accountId: String?
    var credentials: [SavedCredential]
    var pid: SavedCredential?

    init(
      id: Int = 0,
      deviceId: String = UUID().uuidString,
      accountId: String? = nil,
      credentials: [SavedCredential] = [],
      pid: SavedCredential? = nil
    ) {
      self.id = id
      self.deviceId = deviceId
      self.accountId = accountId
      self.credentials = credentials
      self.pid = pid
    }
  }
}

extension SchemaV1 {
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
