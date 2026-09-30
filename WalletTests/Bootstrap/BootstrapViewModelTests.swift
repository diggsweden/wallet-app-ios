import Foundation
import SwiftAccessMechanism
import SwiftData
import Testing
import WalletGatewayInterface

@testable import User
@testable import WalletDemo

@MainActor
@Suite("Bootstrap", .serialized)
struct BootstrapViewModelTests {
  @Test("The first successful check saves a baseline without resetting an existing wallet")
  func firstCheckSavesBaseline() async throws {
    let store = try makeStore()
    let gateway = DatabaseUpdateGateway()
    let viewModel = makeViewModel(store: store, gateway: gateway)

    await viewModel.bootstrap()
    let user = try #require(loadedUser(viewModel))

    #expect(user.hasCompletedOnboarding)
    #expect(!user.isReset)
    #expect(user.backendResetAt == DatabaseUpdateGateway.timestamp)
    #expect(user.accountId == "account")
    #expect(try await UserStore(modelContainer: store.modelContainer).getOrCreate() == user)
    #expect(await gateway.calls == 1)
  }

  @Test("An unchanged or older backend timestamp keeps the wallet", arguments: [100.0, 200.0])
  func existingBaseline(timestamp: TimeInterval) async throws {
    let baseline = Date(timeIntervalSince1970: timestamp)
    let store = try makeStore(baseline: baseline)
    let viewModel = makeViewModel(store: store, gateway: DatabaseUpdateGateway())

    await viewModel.bootstrap()
    let user = try #require(loadedUser(viewModel))

    #expect(user.hasCompletedOnboarding)
    #expect(!user.isReset)
    #expect(user.accountId == "account")
    #expect(user.backendResetAt == baseline)
  }

  @Test("A backend failure prevents handoff until a successful retry")
  func backendFailureBlocksAccess() async throws {
    let store = try makeStore()
    let originalUser = try await store.getOrCreate()
    let gateway = DatabaseUpdateGateway(fails: true)
    let viewModel = makeViewModel(store: store, gateway: gateway)
    await viewModel.bootstrap()

    guard case .backendCheckFailed = viewModel.state else {
      Issue.record("Expected the backend check failure state")
      return
    }
    #expect(loadedUser(viewModel) == nil)
    #expect(try await store.getOrCreate() == originalUser)

    await gateway.allowRequests()
    await viewModel.bootstrap()
    #expect(try #require(loadedUser(viewModel)).hasCompletedOnboarding)
    #expect(await gateway.calls == 2)
  }

  @Test("Incomplete onboarding skips the backend")
  func incompleteOnboardingSkipsBackend() async throws {
    let store = try makeStore(onboarded: false)
    let gateway = DatabaseUpdateGateway(fails: true)
    let viewModel = makeViewModel(store: store, gateway: gateway)

    await viewModel.bootstrap()
    let user = try #require(loadedUser(viewModel))

    #expect(!user.hasCompletedOnboarding)
    #expect(user.backendResetAt == nil)
    #expect(await gateway.calls == 0)
  }

  @Test("A migration reset skips the backend and shows the notice before onboarding")
  func migrationReset() async throws {
    let store = try makeStore(isReset: true)
    let gateway = DatabaseUpdateGateway(fails: true)
    let viewModel = makeViewModel(store: store, gateway: gateway)

    await viewModel.bootstrap()
    guard case .accountReset(let dependencies) = viewModel.state else {
      Issue.record("Expected the reset notice")
      return
    }

    #expect(dependencies.userViewModel.user.accountId == nil)
    #expect(dependencies.userViewModel.user.credentials.isEmpty)
    #expect(!dependencies.userViewModel.isOnboardingCompleted)
    #expect(await gateway.calls == 0)
    viewModel.acknowledgeAccountReset(dependencies: dependencies)
    #expect(loadedUser(viewModel) == dependencies.userViewModel.user)
  }

  @Test("A newer timestamp resets the wallet")
  func backendReset() async throws {
    let store = try makeStore(baseline: Date(timeIntervalSince1970: 50))
    let gateway = DatabaseUpdateGateway()
    let viewModel = makeViewModel(store: store, gateway: gateway)

    await viewModel.bootstrap()
    guard case .accountReset(let dependencies) = viewModel.state else {
      Issue.record("Expected the reset notice")
      return
    }

    #expect(dependencies.userViewModel.user.accountId == nil)
    #expect(dependencies.userViewModel.user.credentials.isEmpty)
    #expect(dependencies.userViewModel.user.backendResetAt == nil)
    #expect(await gateway.calls == 1)
  }

  @Test("Onboarding completes only after its baseline has been fetched and saved")
  func onboardingWaitsForBaseline() async throws {
    let store = try makeStore(onboarded: false)
    let gate = Gate()
    let gateway = DatabaseUpdateGateway(gate: gate)
    let viewModel = makeViewModel(store: store, gateway: gateway)
    await viewModel.bootstrap()
    let dependencies = try #require(loadedDependencies(viewModel))

    let completion = Task { try await dependencies.completeOnboarding() }
    await gate.reached()
    defer { gate.open() }
    #expect(!dependencies.userViewModel.isOnboardingCompleted)
    let pendingUser = try await store.getOrCreate()
    #expect(!pendingUser.isOnboardingCompleted)
    #expect(pendingUser.backendResetAt == nil)

    gate.open()
    try await completion.value
    let user = dependencies.userViewModel.user
    #expect(user.hasCompletedOnboarding)
    #expect(user.backendResetAt == DatabaseUpdateGateway.timestamp)
    #expect(try await UserStore(modelContainer: store.modelContainer).getOrCreate() == user)
    #expect(await gateway.calls == 1)
  }

  @Test("A failed baseline fetch leaves onboarding incomplete and can be retried")
  func onboardingBaselineFailure() async throws {
    let store = try makeStore(onboarded: false)
    let originalUser = try await store.getOrCreate()
    let gateway = DatabaseUpdateGateway(fails: true)
    let viewModel = makeViewModel(store: store, gateway: gateway)
    await viewModel.bootstrap()
    let dependencies = try #require(loadedDependencies(viewModel))

    await #expect(throws: GatewayError.self) {
      try await dependencies.completeOnboarding()
    }
    #expect(dependencies.userViewModel.user == originalUser)
    #expect(try await store.getOrCreate() == originalUser)

    await gateway.allowRequests()
    try await dependencies.completeOnboarding()
    #expect(dependencies.userViewModel.isOnboardingCompleted)
    #expect(dependencies.userViewModel.user.backendResetAt == DatabaseUpdateGateway.timestamp)
    #expect(await gateway.calls == 2)
  }

  @Test("A backend reset after onboarding is detected on the next launch")
  func resetAfterOnboarding() async throws {
    let store = try makeStore(onboarded: false)
    let gateway = DatabaseUpdateGateway()
    let viewModel = makeViewModel(store: store, gateway: gateway)
    await viewModel.bootstrap()
    let dependencies = try #require(loadedDependencies(viewModel))
    try await dependencies.completeOnboarding()

    await gateway.setTimestamp(Date(timeIntervalSince1970: 200))
    let reopenedStore = UserStore(modelContainer: store.modelContainer)
    let relaunched = makeViewModel(store: reopenedStore, gateway: gateway)
    await relaunched.bootstrap()

    guard case .accountReset(let resetDependencies) = relaunched.state else {
      Issue.record("Expected the reset after onboarding to be detected")
      return
    }
    #expect(resetDependencies.userViewModel.user.accountId == nil)
    #expect(resetDependencies.userViewModel.user.credentials.isEmpty)
    #expect(await gateway.calls == 2)
  }

  @Test("Signing out clears the baseline and onboarding establishes a new one")
  func onboardingAfterSignOut() async throws {
    let store = try makeStore(baseline: DatabaseUpdateGateway.timestamp)
    let gateway = DatabaseUpdateGateway()
    let viewModel = makeViewModel(store: store, gateway: gateway)
    await viewModel.bootstrap()
    let dependencies = try #require(loadedDependencies(viewModel))
    let userViewModel = dependencies.userViewModel
    let credential = try #require(userViewModel.user.credentials.first)

    try await userViewModel.signOut()
    #expect(userViewModel.user.backendResetAt == nil)
    #expect(!userViewModel.isOnboardingCompleted)
    try await userViewModel.signIn("new-account")
    try await userViewModel.saveCredential(credential)
    let newTimestamp = Date(timeIntervalSince1970: 200)
    await gateway.setTimestamp(newTimestamp)
    try await dependencies.completeOnboarding()

    #expect(userViewModel.isOnboardingCompleted)
    #expect(userViewModel.user.accountId == "new-account")
    #expect(userViewModel.user.backendResetAt == newTimestamp)
    #expect(try await store.getOrCreate() == userViewModel.user)
  }

  @Test("Overlapping startup attempts perform one backend check")
  func overlappingStartup() async throws {
    let store = try makeStore()
    let gate = Gate()
    let gateway = DatabaseUpdateGateway(gate: gate)
    let viewModel = makeViewModel(store: store, gateway: gateway)

    let startup = Task { await viewModel.bootstrap() }
    await gate.reached()
    await viewModel.bootstrap()
    #expect(await gateway.calls == 1)
    gate.open()
    await startup.value
    #expect(loadedUser(viewModel)?.hasCompletedOnboarding == true)
  }
}

private extension BootstrapViewModelTests {
  func loadedDependencies(_ viewModel: BootstrapViewModel) -> AppDependencies? {
    guard case .ready(let dependencies) = viewModel.state else { return nil }
    return dependencies
  }

  func loadedUser(_ viewModel: BootstrapViewModel) -> UserSnapshot? {
    loadedDependencies(viewModel)?.userViewModel.user
  }

  func makeStore(
    onboarded: Bool = true,
    baseline: Date? = nil,
    isReset: Bool = false,
  ) throws -> UserStore {
    let container = try ModelContainer(
      for: SchemaV6.User.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true),
    )
    let context = ModelContext(container)
    context.insert(
      SchemaV6.User(
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
        backendResetAt: baseline,
      )
    )
    try context.save()
    return UserStore(modelContainer: container)
  }

  func makeViewModel(
    store: UserStore,
    gateway: DatabaseUpdateGateway,
  ) -> BootstrapViewModel {
    BootstrapViewModel(dependencies: (store, gateway))
  }
}

private actor DatabaseUpdateGateway: GatewayApi, HSMTransport {
  static let timestamp = Date(timeIntervalSince1970: 100)
  private var responseTimestamp = DatabaseUpdateGateway.timestamp
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

  func setTimestamp(_ timestamp: Date) {
    responseTimestamp = timestamp
  }

  func getDatabaseUpdateTimestamp() async throws -> Date {
    calls += 1
    await gate?.pass()
    if fails { throw GatewayError.invalidResponse }
    return responseTimestamp
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
