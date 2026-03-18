// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import SwiftData
import SwiftUI

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

    self.sessionManager = SessionManager(accountIdProvider: userStore)
    self.gatewayApiClient = GatewayApiClient(sessionManager: sessionManager)
  }

  var body: some Scene {
    WindowGroup {
      AppRootView(
        userStore: userStore,
        gatewayApiClient: gatewayApiClient,
      )
      .withAuthPresentationAnchor
      .themed
      .withOrientation
      .withToast
    }
  }
}
