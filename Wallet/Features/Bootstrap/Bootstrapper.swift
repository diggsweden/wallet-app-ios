// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import User

@MainActor
struct Bootstrapper {
  let services: WalletServices

  func start() async throws -> BootstrapViewModel.State {
    let user = try await services.userStore.getOrCreate()

    if user.isReset || hasStaleDeviceKey(user) {
      return try await signOut(isReset: true)
    }

    if user.hasCompletedOnboarding {
      return try await checkForBackendReset(user)
    }

    return .ready(makeAppDependencies(user: user))
  }

  func signOut(isReset: Bool) async throws -> BootstrapViewModel.State {
    try await services.userStore.deleteWallet()
    let appDependencies = makeAppDependencies(user: try await services.userStore.getOrCreate())
    return isReset ? .accountReset(appDependencies) : .ready(appDependencies)
  }

  private func hasStaleDeviceKey(_ user: UserSnapshot) -> Bool {
    !user.hasCompletedOnboarding && SigningKeyStore.hasKey(withTag: .deviceKey)
  }

  private func checkForBackendReset(_ user: UserSnapshot) async throws -> BootstrapViewModel.State {
    let generation: Int

    do {
      generation = try await services.gatewayApiClient.getDatabaseGeneration()
    } catch {
      return .backendCheckFailed(CaughtError(error))
    }

    guard let previousGeneration = user.backendGeneration else {
      let updated = try await services.userStore.saveBackendGeneration(generation)
      return .ready(makeAppDependencies(user: updated))
    }

    guard generation > previousGeneration else {
      return .ready(makeAppDependencies(user: user))
    }

    return try await signOut(isReset: true)
  }

  private func makeAppDependencies(user: UserSnapshot) -> AppDependencies {
    AppDependencies(
      userViewModel: UserViewModel(user: user, userStore: services.userStore),
      gatewayApiClient: services.gatewayApiClient,
    )
  }
}
