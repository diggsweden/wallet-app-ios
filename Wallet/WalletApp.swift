// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import SwiftData
import SwiftUI
import WalletGateway

@main
struct WalletApp: App {
  private let userStore: UserStore
  private let sessionManager: SessionManager
  private let gatewayApiClient: GatewayApiClient

  init() {
    do {
      userStore = try UserStore()
    } catch {
      fatalError("Failed setting up storage")
    }

    self.sessionManager = SessionManager(
      signingProvider: WalletSessionSigner(),
      accountIdProvider: userStore,
      baseUrl: AppConfig.apiBaseUrl
    )
    self.gatewayApiClient = GatewayApiClient(
      sessionManager: sessionManager,
      apiKey: AppConfig.apiKey,
      baseUrl: AppConfig.apiBaseUrl
    )
  }

  var body: some Scene {
    WindowGroup {
      AppRootView(
        userStore: userStore,
        gatewayApiClient: gatewayApiClient,
      )
      .withWindowBridge
      .themed
      .withOrientation
      .withToast
    }
  }
}
