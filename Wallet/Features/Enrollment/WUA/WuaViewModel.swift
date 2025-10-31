import Foundation

final class WuaViewModel {
  let walletId: UUID
  let keyTag: UUID
  let gatewayClient: GatewayClient

  init(walletId: UUID, keyTag: UUID, gatewayClient: GatewayClient) {
    self.walletId = walletId
    self.keyTag = keyTag
    self.gatewayClient = gatewayClient
  }

  func fetchWua() async throws -> String {
    let key = try KeychainManager.shared.getOrCreateKey(withTag: keyTag.uuidString)
    let jwk = try key.toJWK()

    let jwt = try await gatewayClient.getWalletUnitAttestation(
      walletId: walletId.uuidString,
      jwk: jwk
    )

    return jwt
  }
}
