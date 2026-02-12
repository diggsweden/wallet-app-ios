// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenID4VP

final class OpenID4VPService {
  let walletConfig: OpenId4VPConfiguration
  let sdk: OpenID4VP
  private let certificateTrustMock: CertificateTrust = { _ in
    return true
  }

  init() throws {
    let walletKey = try KeychainService.getOrCreateKey(withTag: .deviceKey)

    walletConfig = OpenId4VPConfiguration(
      privateKey: walletKey,
      publicWebKeySet: try WebKeySet(jwk: walletKey.toECPublicKey()),
      supportedClientIdSchemes: [.x509SanDns(trust: certificateTrustMock)],
      responseEncryptionConfiguration:
        .supported(supportedAlgorithms: [.init(.ECDH_ES)], supportedMethods: [.init(.A128GCM)])
    )

    sdk = OpenID4VP(walletConfiguration: walletConfig)
  }
}
