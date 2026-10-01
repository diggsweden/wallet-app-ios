import Foundation
import SwiftData
import Testing

@testable import User

@Suite("V5 to V6 migration")
struct MigrateV5toV6Tests {
  @Test("Existing wallets migrate without being reset")
  func preservesExistingWallet() async throws {
    let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let url = directory.appending(path: "user.store")
    try createV5Store(at: url)

    let container = try ModelContainer(
      for: SchemaV6.User.self,
      migrationPlan: SwiftDataMigrationPlan.self,
      configurations: ModelConfiguration(url: url),
    )
    let snapshot = try await UserStore(modelContainer: container).getOrCreate()

    #expect(snapshot.accountId == "account")
    #expect(snapshot.isOnboardingCompleted)
    #expect(snapshot.credentials.map(\.keyId) == ["pid-key"])
    #expect(snapshot.hsmServerParameters?.serverJwsPublicKey.kid == "server-key")
    #expect(!snapshot.isReset)
    #expect(snapshot.backendResetAt == nil)
  }

  private func createV5Store(at url: URL) throws {
    let container = try ModelContainer(
      for: SchemaV5.User.self,
      configurations: ModelConfiguration(url: url),
    )
    let context = ModelContext(container)
    context.insert(
      SchemaV5.User(
        accountId: "account",
        credentials: [
          .init(
            issuer: .init(name: "Issuer", info: nil, imageUrl: nil),
            compactSerialized: "header.payload.signature~",
            claimDisplayNames: [:],
            claimsCount: 0,
            issuedAt: Date(timeIntervalSince1970: 123),
            type: "pid",
            keyId: "pid-key",
            displayData: nil,
          )
        ],
        hsmServerParameters: .init(
          serverJwsPublicKey: .init(kty: "EC", crv: "P-256", x: "x", y: "y", kid: "server-key"),
          opaqueContext: Data([1]),
          opaqueServerIdentifier: Data([2]),
        ),
        isOnboardingCompleted: true,
      )
    )
    try context.save()
  }
}
