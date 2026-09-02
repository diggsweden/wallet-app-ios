// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import Jose
import OpenId4VCInterface

public struct FakeProofSigner: ProofSigner {
  public let key = P256.Signing.PrivateKey()

  public init() {}

  // swiftlint:disable:next async_without_await
  public func sign(_ signingInput: Data) async throws -> String {
    try key.signature(for: signingInput).rawRepresentation.base64UrlEncodedString()
  }

  // swiftlint:disable:next async_without_await
  public func publicKey() async throws -> WalletJoseJWK {
    WalletJoseJWK(key.publicKey)
  }
}

public struct FailingProofSigner: ProofSigner {
  public struct Failure: Error {
    public init() {}
  }

  public init() {}

  // swiftlint:disable:next async_without_await
  public func sign(_ signingInput: Data) async throws -> String {
    throw Failure()
  }

  // swiftlint:disable:next async_without_await
  public func publicKey() async throws -> WalletJoseJWK {
    throw Failure()
  }
}
