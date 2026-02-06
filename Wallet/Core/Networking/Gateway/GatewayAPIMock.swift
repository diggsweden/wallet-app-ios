import Foundation
import JOSESwift

struct GatewayAPIMock: GatewayAPI {
  func createAccount(
    personalIdentityNumber: String,
    emailAddress: String,
    telephoneNumber: String?,
    jwk: ECPublicKey,
    oidcSessionId: String,
  ) async throws -> String {
    return ""
  }

  func getWalletUnitAttestation(nonce: String) async throws -> String {
    return ""
  }
}
