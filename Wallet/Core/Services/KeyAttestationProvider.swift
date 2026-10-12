// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Jose
import OpenId4VCInterface
import WalletGatewayInterface

struct KeyAttestationProvider: KeyAttestationProviding {
  let gatewayApiClient: any GatewayApi

  func keyAttestation(for keys: [WalletJoseJWK], nonce: String?) async throws -> String {
    let keyComponents = try keys.map { try $0.toPublicKeyComponents() }
    return try await gatewayApiClient.getKeyAttestation(keys: keyComponents, nonce: nonce)
  }
}
