import Foundation

@MainActor
@Observable
final class CreateAccountViewModel {
  let gatewayAPIClient: GatewayAPI
  let onSubmit: (String, String) async throws -> Void
  var data: CreateAccountFormData
  var accountIdResult: AsyncResult<String> = .idle
  var showAllValidationErrors: Bool = false

  init(
    gatewayAPIClient: GatewayAPI,
    phoneNumber: String?,
    onSubmit: @escaping (String, String) async throws -> Void
  ) {
    self.data = CreateAccountFormData(phoneNumber: phoneNumber)
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
      let key = try KeychainService.getOrCreateKey(withTag: .deviceKey)
      let accountId = try await gatewayAPIClient.createAccount(
        personalIdentityNumber: random12DigitString(),
        emailAddress: data.email,
        telephoneNumber: data.phoneNumber,
        jwk: key.toECPublicKey()
      )

      accountIdResult = .success(accountId)
      try await onSubmit(accountId, data.email)
    } catch {
      accountIdResult = .failure(error)
    }
  }

  private func random12DigitString() -> String {
    (0 ..< 12).map { _ in String(Int.random(in: 0 ... 9)) }.joined()
  }
}
