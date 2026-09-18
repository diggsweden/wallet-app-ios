// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation
import SwiftData
import Testing

@testable import User

@Suite("V4 to V5 migration", .serialized)
struct MigrateV4toV5Tests {
  @Test("The PID key ID is persisted for every credential and user data survives migration")
  // swiftlint:disable:next function_body_length
  func populatesAttestedKeyId() throws {
    let credentials = [
      Self.credential(type: "Document", compactSerialized: "document"),
      Self.credential(
        type: CredentialType.pid.rawValue,
        compactSerialized: Self.pid(
          payload: #"{"cnf":{"jwk":{"kid":"pid-key"}}}"#
        ),
      ),
    ]
    let parameters = SchemaV4.HsmServerParameters(
      serverJwsPublicKey: .init(kty: "EC", crv: "P-256", x: "x", y: "y", kid: "server-key"),
      opaqueContext: Data([1, 2]),
      opaqueServerIdentifier: Data([3, 4]),
    )

    // swiftlint:disable:next closure_body_length
    try withStore { url in
      try createV4Store(at: url) { context in
        context.insert(
          SchemaV4.User(
            id: 1,
            accountId: "account",
            credentials: credentials,
            hsmServerParameters: parameters,
          )
        )
      }
      do {
        let container = try migrateStore(at: url)
        let user = try #require(
          try ModelContext(container).fetch(FetchDescriptor<SchemaV5.User>()).first
        )
        #expect(user.id == 1)
        #expect(user.accountId == "account")
        #expect(!user.isOnboardingCompleted)
        #expect(user.hsmServerParameters?.serverJwsPublicKey.kid == "server-key")
        #expect(user.hsmServerParameters?.opaqueContext == parameters.opaqueContext)
        #expect(
          user.hsmServerParameters?.opaqueServerIdentifier == parameters.opaqueServerIdentifier
        )
        #expect(user.credentials.map(\.attestedKeyId) == ["pid-key", "pid-key"])
        // Decoding as V4 ignores the new field and checks every original credential field.
        let originalValues = try JSONDecoder()
          .decode(
            [SchemaV4.SavedCredential].self,
            from: JSONEncoder().encode(user.credentials),
          )
        #expect(originalValues == credentials)
      }
      let reopened = try ModelContainer(
        for: SchemaV5.User.self,
        configurations: ModelConfiguration(url: url),
      )
      let user = try #require(
        try ModelContext(reopened).fetch(FetchDescriptor<SchemaV5.User>()).first
      )
      #expect(user.credentials.map(\.attestedKeyId) == ["pid-key", "pid-key"])
    }
  }

  @Test("A user without credentials can migrate without a PID")
  func emptyCredentials() throws {
    try withStore { url in
      try createV4Store(at: url) { $0.insert(SchemaV4.User()) }
      let container = try migrateStore(at: url)
      let user = try #require(
        try ModelContext(container).fetch(FetchDescriptor<SchemaV5.User>()).first
      )
      #expect(user.credentials.isEmpty)
      #expect(!user.isOnboardingCompleted)
    }
  }

  @Test(
    "An unusable PID fails migration without changing the V4 credentials",
    arguments: [
      "invalid",
      "e30.!.signature~",
      pid(payload: "not-json"),
      pid(payload: "{}"),
      pid(payload: #"{"cnf":{}}"#),
      pid(payload: #"{"cnf":{"jwk":{}}}"#),
      pid(payload: #"{"cnf":{"jwk":{"kid":""}}}"#),
      pid(payload: #"{"cnf":{"jwk":{"kid":123}}}"#),
    ],
  )
  func invalidPid(compactSerialized: String) throws {
    try assertFailedMigrationPreservesCredentials([
      Self.credential(type: CredentialType.pid.rawValue, compactSerialized: compactSerialized)
    ])
  }

  @Test("Credentials without a PID fail migration without losing data")
  func missingPid() throws {
    try assertFailedMigrationPreservesCredentials([
      Self.credential(type: "Document", compactSerialized: "document")
    ])
  }
}

private extension MigrateV4toV5Tests {
  func withStore(_ body: (URL) throws -> Void) throws {
    let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    try body(directory.appending(path: "user.store"))
  }

  func createV4Store(at url: URL, populate: (ModelContext) throws -> Void) throws {
    let container = try ModelContainer(
      for: SchemaV4.User.self,
      configurations: ModelConfiguration(url: url),
    )
    let context = ModelContext(container)
    try populate(context)
    try context.save()
  }

  func migrateStore(at url: URL) throws -> ModelContainer {
    try ModelContainer(
      for: SchemaV5.User.self,
      migrationPlan: SwiftDataMigrationPlan.self,
      configurations: ModelConfiguration(url: url),
    )
  }

  func assertFailedMigrationPreservesCredentials(_ credentials: [SchemaV4.SavedCredential]) throws {
    try withStore { url in
      try createV4Store(at: url) { $0.insert(SchemaV4.User(credentials: credentials)) }
      #expect(throws: (any Error).self) { try migrateStore(at: url) }
      let container = try ModelContainer(
        for: SchemaV4.User.self,
        configurations: ModelConfiguration(url: url),
      )
      let user = try #require(
        try ModelContext(container).fetch(FetchDescriptor<SchemaV4.User>()).first
      )
      #expect(user.credentials == credentials)
    }
  }

  static func credential(type: String, compactSerialized: String) -> SchemaV4.SavedCredential {
    SchemaV4.SavedCredential(
      issuer: .init(
        name: "Issuer",
        info: "Info",
        imageUrl: URL(string: "https://example.com/logo.png"),
      ),
      compactSerialized: compactSerialized,
      claimDisplayNames: ["given_name": "Name"],
      claimsCount: 1,
      issuedAt: Date(timeIntervalSince1970: 123),
      type: type,
      displayData: .init(name: "Credential"),
    )
  }

  static func pid(payload: String) -> String {
    // Different header and attestation keys ensure the migration reads cnf.jwk.kid.
    let attestationPayload = #"{"attested_keys":[{"kid":"attestation-key"}]}"#
    let attestation = "e30.\(base64Url(attestationPayload)).signature"
    let header = #"{"alg":"ES256","kid":"issuer-key","key_attestation":"\#(attestation)"}"#
    return "\(base64Url(header)).\(base64Url(payload)).signature~disclosure~"
  }

  static func base64Url(_ value: String) -> String {
    Data(value.utf8).base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}
