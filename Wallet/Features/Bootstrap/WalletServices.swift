// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftAccessMechanism
import User
import WalletGateway
import WalletGatewayInterface

struct WalletServices: Sendable {
  let userStore: UserStore
  let gatewayApiClient: any GatewayApi & HSMTransport

  @concurrent
  static func make() async throws -> Self {
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
    return Self(userStore: userStore, gatewayApiClient: gatewayApiClient)
  }
}
