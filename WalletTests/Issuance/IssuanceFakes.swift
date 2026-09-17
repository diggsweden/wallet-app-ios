// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import CryptoKit
import Foundation
import Jose
import OpenId4VCInterface
import SwiftAccessMechanism
import WalletGatewayInterface
import WalletMacros

@testable import WalletDemo

enum FakeError: Error {
  case intentional
}

actor FakeIssuanceFlow: IssuanceFlow {
  enum Operation: Hashable {
    case loadOffer
    case authorizationUrl
    case exchangeAuthorizationCode
    case createProof
    case fetchCredential
  }

  static let authorizationUrl = #URL("https://issuer.example/authorize")

  private var pendingFailures: Set<Operation>
  private(set) var calls: [Operation] = []
  private(set) var callbackUrls: [URL] = []
  private(set) var proofKeys: [ProofKey] = []
  private(set) var proofSigners: [any ProofSigner] = []
  private(set) var attestationProviders: [any KeyAttestationProviding] = []
  private(set) var fetchKeys: [ProofKey] = []

  init(failingOnce failures: Set<Operation> = []) {
    pendingFailures = failures
  }

  func loadOffer(_ offerUri: String) throws -> OfferedIssuance {
    try record(.loadOffer)
    return OfferedIssuance(
      issuer: OfferedIssuer(name: "Issuer", info: "Info", imageUrl: nil)
    )
  }

  func authorizationUrl() throws -> URL {
    try record(.authorizationUrl)
    return Self.authorizationUrl
  }

  func exchangeAuthorizationCode(callbackUrl: URL) throws {
    callbackUrls.append(callbackUrl)
    try record(.exchangeAuthorizationCode)
  }

  func createProof(
    proofKey: ProofKey,
    signer: any ProofSigner,
    attestations: any KeyAttestationProviding,
  ) throws {
    proofKeys.append(proofKey)
    proofSigners.append(signer)
    attestationProviders.append(attestations)
    try record(.createProof)
  }

  func fetchCredential(proofKey: ProofKey) throws -> IssuedCredential {
    fetchKeys.append(proofKey)
    try record(.fetchCredential)
    return IssuedCredential.bound(to: proofKey)
  }

  private func record(_ operation: Operation) throws {
    calls.append(operation)
    if pendingFailures.remove(operation) != nil {
      throw FakeError.intentional
    }
  }
}

actor FakeProofKeyManager: ProofSigner, ProofKeyStore {
  enum Operation: Hashable {
    case authenticate
    case createKey
  }

  private var pendingFailures: Set<Operation>
  private(set) var authenticateCount = 0
  private(set) var createKeyCount = 0
  private(set) var createdKeys: [ProofKey] = []

  init(failingOnce failures: Set<Operation> = []) {
    pendingFailures = failures
  }

  func authenticate() throws {
    authenticateCount += 1
    try failIfPending(.authenticate)
  }

  func createKey() throws -> ProofKey {
    createKeyCount += 1
    try failIfPending(.createKey)
    let key = ProofKey(
      id: ProofKey.ID("hsm-key-\(createdKeys.count + 1)"),
      publicKey: WalletJoseJWK(P256.Signing.PrivateKey().publicKey),
    )
    createdKeys.append(key)
    return key
  }

  func deleteKey(id: ProofKey.ID) {}

  func sign(_ signingInput: Data, keyId: ProofKey.ID) -> String { "signature" }

  private func failIfPending(_ operation: Operation) throws {
    if pendingFailures.remove(operation) != nil {
      throw FakeError.intentional
    }
  }
}

struct FakeGateway: GatewayApi, HSMTransport {
  func createAccount(publicKey: PublicKeyComponents) throws -> String { "" }
  func getKeyAttestation(keys: [PublicKeyComponents], nonce: String?) throws -> String { "" }

  func registerState(
    publicKey: JwkKey,
    overwrite: Bool,
    ttl: String?,
  ) throws -> RegisterStateResponse {
    RegisterStateResponse(devAuthorizationCode: nil)
  }

  func perform(_ request: HSMRequest, operation: HSMOperation) throws -> Data { Data() }
}

@MainActor
final class IssuanceRecorder {
  var pins: [String] = []
  var signers: [FakeProofKeyManager] = []
  var savedCredentials: [SavedCredential] = []
  var completeCount = 0
  var authorizationUrls: [URL] = []
}

extension IssuedCredential {
  static func bound(to proofKey: ProofKey) -> IssuedCredential {
    IssuedCredential(
      credential: SavedCredential(
        issuer: IssuerDisplay(name: "Issuer", info: nil, imageUrl: nil),
        compactSerialized: "header.payload.signature~",
        claimDisplayNames: [:],
        claimsCount: 0,
        issuedAt: Date(timeIntervalSince1970: 0),
        type: "urn:credential",
        keyId: proofKey.id.rawValue,
        displayData: nil,
      ),
      claims: [],
    )
  }
}
