// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
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
      ? #URL("http://localhost/pid-issuer")
      : #URL("https://wallet.sandbox.digg.se/pid-issuer")
  }

  static var apiKey: String {
    useLocalhost
      ? "apikey"
      : "my_secret_key"
  }
}
