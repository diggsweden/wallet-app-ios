import Foundation

@MainActor
final class WuaViewModel {
  let walletId: String
  let gatewayAPIClient: GatewayAPIClient

  init(walletId: String, gatewayAPIClient: GatewayAPIClient) {
    self.walletId = walletId
    self.gatewayAPIClient = gatewayAPIClient
  }

  func fetchWua() async throws -> String {
    let key = try CryptoKeyStore.shared.getOrCreateKey(withTag: .walletKey)
    let jwk = try key.toECPublicKey().toPublicJWK()

    let jwt = try await gatewayAPIClient.getWalletUnitAttestation(
      walletId: walletId,
      jwk: jwk
    )

    return jwt
  }
}
