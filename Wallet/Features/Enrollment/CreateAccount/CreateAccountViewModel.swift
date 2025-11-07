import Foundation

final class CreateAccountViewModel {
  let gatewayClient: GatewayClient
  let keyTag: UUID

  init(gatewayClient: GatewayClient, keyTag: UUID) {
    self.gatewayClient = gatewayClient
    self.keyTag = keyTag
  }

  func createAccount(with data: ContactInfoData) async throws -> String {
    let key = try KeychainManager.shared.fetchKey(withTag: keyTag.uuidString)
    return ""
    //    return try await gatewayClient.createAccount(
    //      personalIdentityNumber: data.pin,
    //      emailAddress: data.email,
    //      telephoneNumber: data.phoneNumber,
    //      jwk: key.toJWK()
    //    )
  }
}
