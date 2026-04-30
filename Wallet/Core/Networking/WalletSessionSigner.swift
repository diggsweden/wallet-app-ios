// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import JSONWebSignature
import WalletGateway

struct WalletSessionSigner: SessionSigningProvider {
  func keyId() throws -> String {
    let key = try SigningKeyStore.getOrCreateKey(withTag: .walletKey)
    guard let keyId = try? key.publicKey.jwk.thumbprint() else {
      throw SessionError.noKeyId
    }
    return keyId
  }

  func signSessionJwt(keyId: String, nonce: String) throws -> String {
    struct SessionPayload: Codable {
      let nonce: String
    }
    let key = try SigningKeyStore.getOrCreateKey(withTag: .walletKey)
    let header = DefaultJWSHeaderImpl(algorithm: .ES256, keyID: keyId)
    let payload = SessionPayload(nonce: nonce)
    return try JwtUtil().signJwt(with: key, payload: payload, header: header)
  }
}
