// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import WalletGateway

@MainActor
@Observable
final class CreateAccountViewModel {
  let gatewayApiClient: GatewayApi
  let onSubmit: (String, String) async throws -> Void
  var data: CreateAccountFormData
  var accountIdResult: AsyncResult<String> = .idle
  var showAllValidationErrors: Bool = false

  init(
    gatewayApiClient: GatewayApi,
    phoneNumber: String?,
    onSubmit: @escaping (String, String) async throws -> Void,
  ) {
    self.data = CreateAccountFormData(phoneNumber: phoneNumber)
    self.gatewayApiClient = gatewayApiClient
    self.onSubmit = onSubmit
  }

  func createAccount() async {
    guard data.isValid else {
      showAllValidationErrors = true
      return
    }

    accountIdResult = .loading
    do {
      let key = try SigningKeyStore.getOrCreateKey(withTag: .walletKey)
      let accountId = try await gatewayApiClient.createAccount(
        publicKey: try key.publicKey.toPublicKeyComponents()
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
