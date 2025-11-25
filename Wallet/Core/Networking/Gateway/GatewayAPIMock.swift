import Foundation
import JOSESwift

struct GatewayAPIMock: GatewayAPI {
  func createAccount(
    personalIdentityNumber: String,
    emailAddress: String,
    telephoneNumber: String?,
    jwk: PublicJWK
  ) async throws -> String {
    return ""
  }

  func getWalletUnitAttestation(walletId: String, jwk: PublicJWK) async throws -> String {
    return ""
  }
}
