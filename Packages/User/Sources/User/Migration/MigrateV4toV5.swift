// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation
import SwiftData

enum MigrateV4toV5 {
  enum MigrationError: Error {
    case missingPid
    case invalidPid
    case missingAttestedKeyId
  }

  static let stage = MigrationStage.custom(
    fromVersion: SchemaV4.self,
    toVersion: SchemaV5.self,
    willMigrate: { context in
      // Validate before advancing the store version so failures leave the V4 data intact.
      for user in try context.fetch(FetchDescriptor<SchemaV4.User>())
      where !user.credentials.isEmpty {
        guard let pid = user.credentials.first(where: { $0.type == CredentialType.pid.rawValue })
        else {
          throw MigrationError.missingPid
        }
        _ = try attestedKeyId(from: pid.compactSerialized)
      }
    },
    didMigrate: { context in
      for user in try context.fetch(FetchDescriptor<SchemaV5.User>())
      where !user.credentials.isEmpty {
        guard let pid = user.credentials.first(where: { $0.type == CredentialType.pid.rawValue })
        else {
          throw MigrationError.missingPid
        }
        let keyId = try attestedKeyId(from: pid.compactSerialized)
        user.credentials = user.credentials.map { credential in
          SchemaV5.SavedCredential(
            issuer: credential.issuer,
            compactSerialized: credential.compactSerialized,
            claimDisplayNames: credential.claimDisplayNames,
            claimsCount: credential.claimsCount,
            issuedAt: credential.issuedAt,
            type: credential.type,
            attestedKeyId: keyId,
            displayData: credential.displayData,
          )
        }
      }
      try context.save()
    },
  )

  private static func attestedKeyId(from compactSerialized: String) throws -> String {
    let jwt = compactSerialized.prefix { $0 != "~" }
    let parts = jwt.split(separator: ".", omittingEmptySubsequences: false)
    guard parts.count == 3 else { throw MigrationError.invalidPid }

    var payload = parts[1].replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    payload += String(repeating: "=", count: (4 - payload.count % 4) % 4)
    guard let data = Data(base64Encoded: payload),
      let claims = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    else {
      throw MigrationError.invalidPid
    }
    guard let confirmation = claims["cnf"] as? [String: Any],
      let jwk = confirmation["jwk"] as? [String: Any],
      let keyId = jwk["kid"] as? String,
      !keyId.isEmpty
    else {
      throw MigrationError.missingAttestedKeyId
    }
    return keyId
  }
}
