// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SDWebImageWebPCoder
import SwiftAccessMechanism
import SwiftUI
import User
import WalletGateway
import WalletGatewayInterface

typealias Dependencies = (
  userStore: UserStore,
  gatewayApiClient: any GatewayApi & HSMTransport
)

@MainActor
@Observable
final class BootstrapViewModel {
  enum State {
    case loading
    case accountReset(AppDependencies)
    case ready(AppDependencies)
    case error(CaughtError)
    case backendCheckFailed(CaughtError)
  }

  private(set) var state: State = .loading
  private var isBootstrapping = false
  private let dependencies: Dependencies

  init(dependencies: Dependencies? = nil) {
    self.dependencies = dependencies ?? Self.makeDependencies()
    DesignSystem.registerFonts()
  }

  func bootstrap() async {
    guard !isBootstrapping else { return }
    isBootstrapping = true
    state = .loading
    defer { isBootstrapping = false }

    do {
      let userSnapshot = try await dependencies.userStore.getOrCreate()

      if userSnapshot.isReset || hasStaleDeviceKey(userSnapshot) {
        state = try await signOut(isReset: userSnapshot.isReset)
        return
      }

      if userSnapshot.hasCompletedOnboarding {
        state = try await checkDatabaseUpdate(for: userSnapshot)
        return
      }

      state = .ready(try await makeAppDependencies())
    } catch {
      state = .error(CaughtError(error))
    }
  }

  func signOut() async {
    do {
      state = try await signOut(isReset: false)
    } catch {
      state = .error(CaughtError(error))
    }
  }

  func acknowledgeAccountReset(dependencies: AppDependencies) {
    state = .ready(dependencies)
  }

  private func signOut(isReset: Bool) async throws -> BootstrapViewModel.State {
    let userStore = dependencies.userStore
    try await deleteUser(userStore)
    let appDependencies = try await makeAppDependencies()
    return isReset ? .accountReset(appDependencies) : .ready(appDependencies)
  }

  private func hasStaleDeviceKey(_ user: UserSnapshot) -> Bool {
    !user.hasCompletedOnboarding && SigningKeyStore.hasKey(withTag: .deviceKey)
  }

  private func deleteUser(_ userStore: UserStore) async throws {
    try await userStore.deleteAll()
    try SecKeyStore.deleteAll()
    try SigningKeyStore.deleteAll()
  }

  private func checkDatabaseUpdate(
    for initialSnapshot: UserSnapshot
  ) async throws -> BootstrapViewModel.State {
    let userStore = dependencies.userStore
    let timestamp: Date

    do {
      timestamp = try await dependencies.gatewayApiClient.getDatabaseUpdateTimestamp()
    } catch {
      return .backendCheckFailed(CaughtError(error))
    }

    guard let previousTimestamp = initialSnapshot.backendResetAt else {
      _ = try await userStore.saveBackendResetTimestamp(timestamp)
      let appDependencies = try await makeAppDependencies()
      return .ready(appDependencies)
    }

    guard timestamp > previousTimestamp else {
      let appDependencies = try await makeAppDependencies()
      return .ready(appDependencies)
    }
    return try await signOut(isReset: true)
  }

  private func makeAppDependencies() async throws -> AppDependencies {
    let userViewModel = UserViewModel(
      user: try await dependencies.userStore.getOrCreate(),
      userStore: dependencies.userStore,
    )
    let gatewayApiClient = dependencies.gatewayApiClient

    return AppDependencies(
      userViewModel: userViewModel,
      gatewayApiClient: gatewayApiClient,
      completeOnboarding: {
        let timestamp = try await gatewayApiClient.getDatabaseUpdateTimestamp()
        try await userViewModel.completeOnboarding(backendResetAt: timestamp)
      },
    )
  }

  private static func makeDependencies() -> Dependencies {
    do {
      let userStore = try UserStore()
      let system = SystemInfoProvider.shared.snapshot()
      let deviceInfo = DeviceInfo(
        os: "iOS",
        osVersion: system.iosVersion,
        model: system.deviceModel,
        appVersion: system.appVersion,
      )
      let sessionManager = SessionManager(
        signingProvider: WalletSessionSigner(),
        accountIdProvider: userStore,
        baseUrl: AppConfig.apiBaseUrl,
        deviceInfo: deviceInfo,
      )
      let gatewayApiClient = GatewayApiClient(
        sessionManager: sessionManager,
        apiKey: AppConfig.apiKey,
        baseUrl: AppConfig.apiBaseUrl,
        deviceInfo: deviceInfo,
      )
      SDImageCodersManager.shared.addCoder(SDImageAWebPCoder.shared)
      return (userStore, gatewayApiClient)
    } catch {
      fatalError("Failed to create database")
    }
  }
}
