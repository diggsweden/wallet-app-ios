import AuthenticationServices
import Foundation

@MainActor
@Observable
final class OnboardingPidViewModel {
  private let walletId: String
  private let gatewayAPIClient: GatewayAPI
  private let onSubmit: (String) throws -> Void
  private let oAuthCoordinator = OAuthCoordinator()

  init(
    walletId: String,
    gatewayAPIClient: GatewayAPI,
    onSubmit: @escaping (String) throws -> Void
  ) {
    self.walletId = walletId
    self.gatewayAPIClient = gatewayAPIClient
    self.onSubmit = onSubmit
  }

  func fetchPid(_ authAnchor: ASPresentationAnchor?) async throws {
    let credentialOfferUri = try await oAuthCoordinator.start(
      url: AppConfig.pidIssuerURL,
      callbackScheme: "openid-credential-offer",
      anchor: authAnchor,
    )

    guard credentialOfferUri.queryItemValue(for: "credential_offer") != nil
    else {
      throw OnboardingError.pidFailure
    }

    try onSubmit(credentialOfferUri.absoluteString)
  }
}
