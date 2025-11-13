import Foundation

@MainActor
@Observable
final class CreateAccountViewModel {
  let gatewayAPIClient: GatewayAPIClient
  let onSubmit: (String) async throws -> Void
  var data = CreateAccountFormData()
  var accountIdResult: AsyncResult<String> = .idle
  var showAllValidationErrors: Bool = false

  init(
    gatewayAPIClient: GatewayAPIClient,
    onSubmit: @escaping (String) async throws -> Void
  ) {
    self.gatewayAPIClient = gatewayAPIClient
    self.onSubmit = onSubmit
  }

  func createAccount() async {
    guard data.isValid else {
      showAllValidationErrors = true
      return
    }

    accountIdResult = .loading
    do {
      let key = try CryptoKeyStore.shared.getOrCreateKey(withTag: .deviceKey)
      let accountId = try await gatewayAPIClient.createAccount(
        personalIdentityNumber: random12DigitString(),
        emailAddress: data.email,
        telephoneNumber: data.phoneNumber,
        jwk: key.toJWK()
      )

      accountIdResult = .success(accountId)
      try await onSubmit(accountId)
    } catch {
      accountIdResult = .failure(error)
    }
  }

  private func random12DigitString() -> String {
    (0 ..< 12).map { _ in String(Int.random(in: 0 ... 9)) }.joined()
  }
}
