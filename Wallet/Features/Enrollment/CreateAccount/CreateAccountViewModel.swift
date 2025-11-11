import Foundation

@MainActor
@Observable
final class CreateAccountViewModel {
  let gatewayClient: GatewayClient
  let keyTag: UUID
  let onSubmit: (String) async throws -> Void
  var data = CreateAccountFormData()
  var accountIdResult: AsyncResult<String> = .idle

  init(
    gatewayClient: GatewayClient,
    keyTag: UUID,
    onSubmit: @escaping (String) async throws -> Void
  ) {
    self.gatewayClient = gatewayClient
    self.keyTag = keyTag
    self.onSubmit = onSubmit
  }

  func createAccount() async {
    guard data.isValid else {
      return
    }

    accountIdResult = .loading
    do {
      let key = try KeychainManager.shared.fetchKey(withTag: keyTag.uuidString)
      let accountId = try await gatewayClient.createAccount(
        personalIdentityNumber: data.pin,
        emailAddress: data.email,
        telephoneNumber: data.phoneNumber,
        jwk: key.toJWK(kid: keyTag.uuidString)
      )
      accountIdResult = .success(accountId)
      try await onSubmit(accountId)
    } catch {
      accountIdResult = .failure(error)
    }
  }
}
