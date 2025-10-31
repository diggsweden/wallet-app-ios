import SwiftUI
import WalletMacrosClient

private struct GatewayClientKey: EnvironmentKey {
  static let defaultValue = GatewayClient()
}

extension EnvironmentValues {
  var gatewayClient: GatewayClient {
    get { self[GatewayClientKey.self] }
    set { self[GatewayClientKey.self] = newValue }
  }
}
