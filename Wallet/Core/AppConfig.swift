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
}
