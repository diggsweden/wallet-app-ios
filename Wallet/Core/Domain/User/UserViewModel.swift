// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import SwiftAccessMechanism
import SwiftUI
import User
import WalletGatewayInterface

@MainActor
@Observable
final class UserViewModel {
  private(set) var user: UserSnapshot
  private let userStore: UserStore
  private let gatewayApiClient: any GatewayApi

  init(user: UserSnapshot, userStore: UserStore, gatewayApiClient: any GatewayApi) {
    self.user = user
    self.userStore = userStore
    self.gatewayApiClient = gatewayApiClient
  }

  var isOnboardingCompleted: Bool {
    user.hasCompletedOnboarding
  }

  func signIn(_ accountId: String) async throws {
    let updated = try await userStore.addAccountId(accountId)
    user = updated
  }

  func signOut() async throws {
    try await userStore.deleteAll()
    try SecKeyStore.deleteAll()
    try SigningKeyStore.deleteAll()
    let newUser = try await userStore.getOrCreate()
    user = newUser
  }

  func saveCredential(_ credential: SavedCredential) async throws {
    let updated = try await userStore.addCredential(credential)
    user = updated
  }

  func saveHsmServerParameters(_ parameters: ServerParameters) async throws {
    let updated = try await userStore.saveHsmServerParameters(HsmServerParameters(parameters))
    user = updated
  }

  func completeOnboarding() async throws {
    let generation = try await gatewayApiClient.getDatabaseGeneration()
    let updated = try await userStore.completeOnboarding(backendGeneration: generation)
    user = updated
  }
}
