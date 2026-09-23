// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation
import SwiftData
import Testing

@testable import User

@Suite("UserStore")
struct UserStoreTests {
  @Test("A saved credential keeps the key ID it is bound to")
  func credentialKeepsKeyId() async throws {
    let container = try Self.inMemoryContainer()
    let credential = Self.credential(keyId: "hsm-key-1")

    let snapshot = try await UserStore(modelContainer: container).addCredential(credential)
    let reloaded = try await UserStore(modelContainer: container).getOrCreate()

    #expect(snapshot.credentials == [credential])
    #expect(reloaded.credentials.map(\.keyId) == ["hsm-key-1"])
  }

  @Test("Credentials issued to different keys keep their own key IDs")
  func credentialsKeepTheirOwnKeyIds() async throws {
    let store = UserStore(modelContainer: try Self.inMemoryContainer())

    _ = try await store.addCredential(Self.credential(type: "pid", keyId: "pid-key"))
    let snapshot = try await store.addCredential(Self.credential(type: "doc", keyId: "doc-key"))

    #expect(snapshot.credentials.map(\.keyId) == ["pid-key", "doc-key"])
  }

  @Test("Completing onboarding is persisted")
  func completeOnboarding() async throws {
    let container = try Self.inMemoryContainer()

    let before = try await UserStore(modelContainer: container).getOrCreate()
    _ = try await UserStore(modelContainer: container).completeOnboarding()
    let after = try await UserStore(modelContainer: container).getOrCreate()

    #expect(!before.isOnboardingCompleted)
    #expect(after.isOnboardingCompleted)
  }
}

private extension UserStoreTests {
  static func inMemoryContainer() throws -> ModelContainer {
    try ModelContainer(
      for: User.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true),
    )
  }

  static func credential(type: String = "pid", keyId: String) -> SavedCredential {
    SavedCredential(
      issuer: IssuerDisplay(name: "Issuer", info: nil, imageUrl: nil),
      compactSerialized: "header.payload.signature~",
      claimDisplayNames: ["given_name": "Förnamn"],
      claimsCount: 1,
      issuedAt: Date(timeIntervalSince1970: 123),
      type: type,
      keyId: keyId,
      displayData: CredentialDisplayData(name: "Credential"),
    )
  }
}
