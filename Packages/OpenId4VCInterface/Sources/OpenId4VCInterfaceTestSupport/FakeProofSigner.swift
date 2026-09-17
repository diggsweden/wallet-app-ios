// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfacesTestSupport
import CryptoKit
import Foundation
import Jose
import OpenId4VCInterface

/// Signs with a local P-256 key and records which proof key each signature was requested for.
/// By default its key ID matches the one `SampleCredential` is bound to.
public actor FakeProofSigner: ProofSigner {
  nonisolated public let key = P256.Signing.PrivateKey()
  nonisolated public let keyId: ProofKey.ID
  public private(set) var signedKeyIds: [ProofKey.ID] = []

  nonisolated public var proofKey: ProofKey {
    ProofKey(id: keyId, publicKey: WalletJoseJWK(key.publicKey))
  }

  public init(keyId: ProofKey.ID = ProofKey.ID(SampleCredential.keyId)) {
    self.keyId = keyId
  }

  // swiftlint:disable:next async_without_await
  public func sign(_ signingInput: Data, keyId: ProofKey.ID) async throws -> String {
    signedKeyIds.append(keyId)
    return try key.signature(for: signingInput).rawRepresentation.base64UrlEncodedString()
  }
}

public struct FailingProofSigner: ProofSigner {
  public struct Failure: Error {
    public init() {}
  }

  public init() {}

  // swiftlint:disable:next async_without_await
  public func sign(_ signingInput: Data, keyId: ProofKey.ID) async throws -> String {
    throw Failure()
  }
}
