// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import WalletMacrosClient

enum AppConfig {
  static var apiBaseURL: URL {
    #if LOCALHOST
      #URL("http://localhost:8082/wallet-client-gateway")
    #else
      #URL("https://wallet.sandbox.digg.se/api")
    #endif
  }

  static var pidIssuerURL: URL {
    #if LOCALHOST
      #URL("http://localhost/pid-issuer")
    #else
      #URL("https://wallet.sandbox.digg.se/pid-issuer")
    #endif
  }

  static var apiKey: String {
    Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? ""
  }
}
