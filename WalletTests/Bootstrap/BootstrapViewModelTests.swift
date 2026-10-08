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
    #expect(user.backendGeneration == DatabaseUpdateGateway.generation)
    #expect(user.accountId == "account")
    #expect(try await UserStore(modelContainer: store.modelContainer).getOrCreate() == user)
    #expect(await gateway.calls == 1)
  }

  @Test("An unchanged or older backend generation keeps the wallet", arguments: [100, 200])
  func existingBaseline(generation: Int) async throws {
    let baseline = generation
    let store = try makeStore(baseline: baseline)
    let viewModel = makeViewModel(store: store, gateway: DatabaseUpdateGateway())

    await viewModel.bootstrap()
    let user = try #require(loadedUser(viewModel))

    #expect(user.hasCompletedOnboarding)
    #expect(!user.isReset)
    #expect(user.accountId == "account")
    #expect(user.backendGeneration == baseline)
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
    #expect(user.backendGeneration == nil)
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

  @Test("A newer generation resets the wallet")
  func backendReset() async throws {
    let store = try makeStore(baseline: 50)
    let gateway = DatabaseUpdateGateway()
    let viewModel = makeViewModel(store: store, gateway: gateway)

    await viewModel.bootstrap()
    guard case .accountReset(let dependencies) = viewModel.state else {
      Issue.record("Expected the reset notice")
      return
    }

    #expect(dependencies.userViewModel.user.accountId == nil)
    #expect(dependencies.userViewModel.user.credentials.isEmpty)
    #expect(dependencies.userViewModel.user.backendGeneration == nil)
    #expect(await gateway.calls == 1)
  }

  @Test("Wallet setup saves its baseline before onboarding completes")
  func onboardingSavesBaselineDuringSetup() async throws {
    let store = try makeStore(onboarded: false)
    let gateway = DatabaseUpdateGateway(fails: true)
    let viewModel = makeViewModel(store: store, gateway: gateway)
    await viewModel.bootstrap()
    let dependencies = try #require(loadedDependencies(viewModel))
    let userViewModel = dependencies.userViewModel

    try await userViewModel.saveBackendGeneration(DatabaseUpdateGateway.generation)
    #expect(!userViewModel.isOnboardingCompleted)
    #expect(userViewModel.user.backendGeneration == DatabaseUpdateGateway.generation)
    #expect(try await store.getOrCreate() == userViewModel.user)

    try await userViewModel.completeOnboarding()
    #expect(userViewModel.isOnboardingCompleted)
    #expect(userViewModel.user.backendGeneration == DatabaseUpdateGateway.generation)
    #expect(
      try await UserStore(modelContainer: store.modelContainer).getOrCreate() == userViewModel.user
    )
    #expect(await gateway.calls == 0)
  }

  @Test("Wallet setup fetches and saves the baseline through onboarding actions")
  func walletSetupSavesBaseline() async throws {
    let store = try makeStore(onboarded: false)
    let gate = Gate()
    let gateway = DatabaseUpdateGateway(gate: gate)
    let userViewModel = UserViewModel(user: try await store.getOrCreate(), userStore: store)
    let onboarding = OnboardingViewModel(
      actions: .init(
        signIn: userViewModel.signIn,
        saveCredential: userViewModel.saveCredential,
        resetSession: userViewModel.signOut,
        saveHsmServerParameters: userViewModel.saveHsmServerParameters,
        saveBackendGeneration: userViewModel.saveBackendGeneration,
        onComplete: userViewModel.completeOnboarding,
      )
    )
    let service = BFFWalletSetupService(
      gatewayApi: gateway,
      onAccountCreated: { _ in },
      onServerParameters: { _ in },
      onBackendGeneration: { generation in
        try await onboarding.saveBackendGeneration(generation)
      },
    )

    let setup = Task { try await service.setInitialBackendGeneration() }
    await gate.reached()
    defer { gate.open() }
    #expect(userViewModel.user.backendGeneration == nil)

    gate.open()
    try await setup.value
    #expect(userViewModel.user.backendGeneration == DatabaseUpdateGateway.generation)
    #expect(!userViewModel.isOnboardingCompleted)
    #expect(try await store.getOrCreate() == userViewModel.user)
    #expect(await gateway.calls == 1)
  }

  @Test("A failed setup baseline fetch leaves the stored user unchanged and can be retried")
  func walletSetupBaselineFailure() async throws {
    let store = try makeStore(onboarded: false)
    let original = try await store.getOrCreate()
    let gateway = DatabaseUpdateGateway(fails: true)
    let userViewModel = UserViewModel(user: original, userStore: store)
    let service = BFFWalletSetupService(
      gatewayApi: gateway,
      onAccountCreated: { _ in },
      onServerParameters: { _ in },
      onBackendGeneration: { generation in
        try await userViewModel.saveBackendGeneration(generation)
      },
    )

    await #expect(throws: GatewayError.self) {
      try await service.setInitialBackendGeneration()
    }
    #expect(userViewModel.user == original)
    #expect(try await store.getOrCreate() == original)

    await gateway.allowRequests()
    try await service.setInitialBackendGeneration()
    #expect(userViewModel.user.backendGeneration == DatabaseUpdateGateway.generation)
    #expect(!userViewModel.isOnboardingCompleted)
    #expect(await gateway.calls == 2)
  }

  @Test("A backend reset after onboarding is detected on the next launch")
  func resetAfterOnboarding() async throws {
    let store = try makeStore(onboarded: false)
    let gateway = DatabaseUpdateGateway()
    let viewModel = makeViewModel(store: store, gateway: gateway)
    await viewModel.bootstrap()
    let dependencies = try #require(loadedDependencies(viewModel))
    try await dependencies.userViewModel.saveBackendGeneration(
      try await gateway.getDatabaseGeneration()
    )
    try await dependencies.userViewModel.completeOnboarding()

    await gateway.setGeneration(200)
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
    let store = try makeStore(baseline: DatabaseUpdateGateway.generation)
    let gateway = DatabaseUpdateGateway()
    let viewModel = makeViewModel(store: store, gateway: gateway)
    await viewModel.bootstrap()
    let dependencies = try #require(loadedDependencies(viewModel))
    let userViewModel = dependencies.userViewModel
    let credential = try #require(userViewModel.user.credentials.first)

    try await userViewModel.signOut()
    #expect(userViewModel.user.backendGeneration == nil)
    #expect(!userViewModel.isOnboardingCompleted)
    try await userViewModel.signIn("new-account")
    try await userViewModel.saveCredential(credential)
    let newGeneration = 200
    await gateway.setGeneration(newGeneration)
    try await userViewModel.saveBackendGeneration(try await gateway.getDatabaseGeneration())
    try await userViewModel.completeOnboarding()

    #expect(userViewModel.isOnboardingCompleted)
    #expect(userViewModel.user.accountId == "new-account")
    #expect(userViewModel.user.backendGeneration == newGeneration)
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
