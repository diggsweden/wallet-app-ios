// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftAccessMechanism
import SwiftData
import WalletGatewayInterface

@testable import User
@testable import WalletDemo

extension BootstrapViewModelTests {
  func loadedDependencies(_ viewModel: BootstrapViewModel) -> AppDependencies? {
    guard case .ready(let dependencies) = viewModel.state else { return nil }
    return dependencies
  }

  func loadedUser(_ viewModel: BootstrapViewModel) -> UserSnapshot? {
    loadedDependencies(viewModel)?.userViewModel.user
  }

  func makeStore(
    onboarded: Bool = true,
    baseline: Int? = nil,
    isReset: Bool = false,
  ) throws -> UserStore {
    let container = try ModelContainer(
      for: SchemaV5.User.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true),
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
            issuedAt: .distantPast,
            type: "pid",
            keyId: "pid-key",
            displayData: nil,
          )
        ],
        isOnboardingCompleted: onboarded,
        isReset: isReset,
        backendGeneration: baseline,
      )
    )
    try context.save()
    return UserStore(modelContainer: container)
  }

  func makeViewModel(
    store: UserStore,
    gateway: DatabaseUpdateGateway,
  ) -> BootstrapViewModel {
    BootstrapViewModel(makeServices: {
      WalletServices(userStore: store, gatewayApiClient: gateway)
    })
  }
}

actor AttemptCounter {
  private(set) var value = 0

  @discardableResult
  func increment() -> Int {
    value += 1
    return value
  }
}

actor DatabaseUpdateGateway: GatewayApi, HSMTransport {
  static let generation = 100
  private var responseGeneration = DatabaseUpdateGateway.generation
  private var fails: Bool
  private let gate: Gate?
  private(set) var calls = 0

  init(fails: Bool = false, gate: Gate? = nil) {
    self.fails = fails
    self.gate = gate
  }

  func allowRequests() {
    fails = false
  }

  func setGeneration(_ generation: Int) {
    responseGeneration = generation
  }

  func getDatabaseGeneration() async throws -> Int {
    calls += 1
    await gate?.pass()
    if fails { throw GatewayError.invalidResponse }
    return responseGeneration
  }

  func createAccount(publicKey: PublicKeyComponents) -> String { "" }
  func getKeyAttestation(keys: [PublicKeyComponents], nonce: String?) -> String { "" }

  func registerState(
    publicKey: JwkKey,
    overwrite: Bool,
    ttl: String?,
  ) throws -> RegisterStateResponse {
    throw CocoaError(.featureUnsupported)
  }

  func perform(_ request: HSMRequest, operation: HSMOperation) throws -> Data {
    throw CocoaError(.featureUnsupported)
  }
}
