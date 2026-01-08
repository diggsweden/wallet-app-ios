import Foundation
import SiopOpenID4VP

final class OpenID4VPService {
  let walletConfig: SiopOpenId4VPConfiguration
  let sdk: SiopOpenID4VP
  private let certificateTrustMock: CertificateTrust = { _ in
    return true
  }

  init() throws {
    let walletKey = try KeychainService.getOrCreateKey(withTag: .deviceKey)

    walletConfig = SiopOpenId4VPConfiguration(
      subjectSyntaxTypesSupported: [.jwkThumbprint],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: .did("not_supported"),
      signingKey: walletKey,
      publicWebKeySet: try WebKeySet(jwk: walletKey.toECPublicKey()),
      supportedClientIdSchemes: [
        .x509SanDns(trust: certificateTrustMock)
      ],
      vpFormatsSupported: [.jwtType(.jwt_vc)],
      jarmConfiguration:
        .encryption(
          try JARMConfiguration
            .Encryption(
              supportedAlgorithms: [
                .init(.RSA1_5),
                .init(.ECDH_ES),
              ],
              supportedMethods: [.init(.A128GCM)]
            )
        )
    )

    sdk = SiopOpenID4VP(walletConfiguration: walletConfig)
  }
}
