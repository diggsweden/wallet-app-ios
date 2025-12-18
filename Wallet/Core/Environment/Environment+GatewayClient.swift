import SwiftUI
import WalletMacrosClient

extension EnvironmentValues {
  @Entry var gatewayAPIClient = GatewayAPIClient(
    sessionManager: SessionManager(
      accountIDProvider: NilAccountIDProvider()
    )
  )
}
