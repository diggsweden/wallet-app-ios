import Foundation

@MainActor
@Observable
final class OnboardingPidViewModel {
  let walletId: String
  let gatewayAPIClient: GatewayAPI
  let onSubmit: (String) throws -> Void
  var isLoading: Bool = false

  init(
    walletId: String,
    gatewayAPIClient: GatewayAPI,
    onSubmit: @escaping (String) throws -> Void
  ) {
    self.walletId = walletId
    self.gatewayAPIClient = gatewayAPIClient
    self.onSubmit = onSubmit
  }

  func fetchWua() async throws {
    defer {
      isLoading = false
    }

    isLoading = true

    let key = try KeychainService.shared.getOrCreateKey(withTag: .walletKey)
    let jwk = try key.toECPublicKey()

    let jwt = try await gatewayAPIClient.getWalletUnitAttestation(
      walletId: walletId,
      jwk: jwk
    )

    try onSubmit(jwt)
  }
}
