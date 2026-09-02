// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import Jose
import OpenId4VCInterface

struct FakeProofSigner: ProofSigner {
  let key = P256.Signing.PrivateKey()

  // swiftlint:disable:next async_without_await
  func sign(_ signingInput: Data) async throws -> String {
    try key.signature(for: signingInput).rawRepresentation.base64UrlEncodedString()
  }
}
