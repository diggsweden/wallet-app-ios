// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Jose
import OpenId4VCInterface
import WalletGatewayInterface

struct KeyAttestationProvider: KeyAttestationProviding {
  let gatewayApiClient: any GatewayApi

  func keyAttestation(for: [WalletJoseJWK], nonce: String?) async throws -> String {
    try await gatewayApiClient.getWalletUnitAttestation(nonce: nonce)
  }
}
