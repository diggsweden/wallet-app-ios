// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import WalletMacrosClient

enum AppConfig {
  static var useLocalhost: Bool {
    #if DEBUG
      ProcessInfo.processInfo.arguments.contains("-LOCALHOST")
    #else
      false
    #endif
  }

  static var apiBaseURL: URL {
    useLocalhost
      ? #URL("http://localhost:8082/wallet-client-gateway")
      : #URL("https://wallet.sandbox.digg.se/api")
  }

  static var pidIssuerURL: URL {
    useLocalhost
      ? #URL("http://192.168.107.14:8080/pid-issuer")
      : #URL("https://wallet.sandbox.digg.se/pid-issuer")
  }

  static var apiKey: String {
    useLocalhost
      ? "apikey"
      : "my_secret_key"
  }
}
