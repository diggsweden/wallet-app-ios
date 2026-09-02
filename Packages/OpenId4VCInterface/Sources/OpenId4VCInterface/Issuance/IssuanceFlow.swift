// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public protocol IssuanceFlow: Sendable {
  func loadOffer(_ offerUri: String) async throws -> OfferedIssuance
  func authorizationUrl() async throws -> URL
  func exchangeAuthorizationCode(callbackUrl: URL) async throws
  func createProof(
    signer: any ProofSigner,
    attestations: any KeyAttestationProviding,
  ) async throws
  func fetchCredential() async throws -> IssuedCredential
}
