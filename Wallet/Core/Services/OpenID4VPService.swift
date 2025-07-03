import Foundation
import SiopOpenID4VP

final class OpenID4VPService {
  let walletConfig: SiopOpenId4VPConfiguration
  let sdk: SiopOpenID4VP
  private let certificateTrustMock: CertificateTrust = { _ in
    return true
  }

  init() throws {
    let walletKey = try KeychainManager.shared.getOrCreateKey(withTag: Constants.bindingKeyTag)

    walletConfig = SiopOpenId4VPConfiguration(
      subjectSyntaxTypesSupported: [.jwkThumbprint],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: .did("not_supported"),
      signingKey: walletKey,
      signingKeySet: try WebKeySet(jwk: walletKey.toJWK()),
      supportedClientIdSchemes: [.x509SanDns(trust: certificateTrustMock)],
      vpFormatsSupported: [.jwtType(.jwt_vc)]
    )

    sdk = SiopOpenID4VP(walletConfiguration: walletConfig)
  }
}
