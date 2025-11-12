import Foundation

@MainActor
final class WuaViewModel {
  let walletId: String
  let keyTag: String
  let gatewayClient: GatewayClient

  init(walletId: String, keyTag: String, gatewayClient: GatewayClient) {
    self.walletId = walletId
    self.keyTag = keyTag
    self.gatewayClient = gatewayClient
  }

  func fetchWua() async throws -> String {
    let key = try KeychainManager.shared.getOrCreateKey(withTag: keyTag)
    let jwk = try key.toJWK()

    let jwt = try await gatewayClient.getWalletUnitAttestation(
      walletId: walletId,
      jwk: jwk
    )

    return jwt
  }
}
