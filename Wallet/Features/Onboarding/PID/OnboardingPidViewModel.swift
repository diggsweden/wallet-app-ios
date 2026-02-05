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
    // TODO: Remove when integrating wua v3
    try onSubmit("")
  }
}
