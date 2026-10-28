// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Jose
import OpenId4VCInterface
import WalletGatewayInterface

struct WalletInstanceAttestationProvider: WalletInstanceAttestationProviding {
  let gatewayApiClient: any GatewayApi

  func walletInstanceAttestation(for publicKey: WalletJoseJWK) async throws -> String {
    try await gatewayApiClient.getWalletInstanceAttestation(key: publicKey.toPublicKeyComponents())
  }
}
