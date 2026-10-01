// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftData

enum SchemaV5: VersionedSchema {
  static var models: [any PersistentModel.Type] {
    [User.self]
  }

  static let versionIdentifier = Schema.Version(5, 0, 0)
}

extension SchemaV5 {
  @Model
  final class User {
    @Attribute(.unique) var id = 0
    var accountId: String?
    var credentials: [SavedCredential]
    var hsmServerParameters: HsmServerParameters?
    var isOnboardingCompleted: Bool = false

    init(
      id: Int = 0,
      accountId: String? = nil,
      credentials: [SavedCredential] = [],
      hsmServerParameters: HsmServerParameters? = nil,
      isOnboardingCompleted: Bool = false,
    ) {
      self.id = id
      self.accountId = accountId
      self.credentials = credentials
      self.hsmServerParameters = hsmServerParameters
      self.isOnboardingCompleted = isOnboardingCompleted
    }
  }
}

extension SchemaV5 {
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
    let keyId: String
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

extension SchemaV5.SavedCredential {
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    issuer = try container.decode(SchemaV5.IssuerDisplay.self, forKey: .issuer)
    compactSerialized = try container.decode(String.self, forKey: .compactSerialized)
    claimDisplayNames = try container.decode([String: String].self, forKey: .claimDisplayNames)
    claimsCount = try container.decode(Int.self, forKey: .claimsCount)
    issuedAt = try container.decode(Date.self, forKey: .issuedAt)
    type = try container.decode(String.self, forKey: .type)
    // V4 values have no key ID. The custom migration fills it from the PID before saving.
    keyId = try container.decodeIfPresent(String.self, forKey: .keyId) ?? ""
    displayData = try container.decodeIfPresent(
      SchemaV5.CredentialDisplayData.self,
      forKey: .displayData,
    )
  }
}
