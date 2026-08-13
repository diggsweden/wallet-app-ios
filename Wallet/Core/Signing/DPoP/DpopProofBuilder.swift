// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import OpenID4VCI

struct DpopProofBuilder: DPoPConstructorType, DpopProofProviding {
  private let privateKey: P256.Signing.PrivateKey

  init(privateKey: P256.Signing.PrivateKey = P256.Signing.PrivateKey()) {
    self.privateKey = privateKey
  }

  func jwt(endpoint: URL, accessToken: String?, nonce: Nonce?) async throws -> String {
    try await proof(
      endpoint: endpoint,
      method: .post,
      accessToken: accessToken,
      nonce: nonce?.value,
    )
  }

  func proof(
    endpoint: URL,
    method: HTTPMethod,
    accessToken: String?,
    nonce: String?,
  ) async throws -> String {
    let claims = DpopProofClaims(
      jti: UUID().uuidString,
      htm: method.rawValue,
      htu: Self.htu(for: endpoint),
      nonce: nonce,
      ath: accessToken.map { token in
        let hash = SHA256.hash(data: Data(token.utf8))
        return Data(hash).base64UrlEncodedString()
      },
    )

    return try await JwtUtil()
      .signJwt(
        payload: claims,
        header: DpopProofHeader(jwk: privateKey.publicKey.jwkRepresentation),
      ) { signingInput in
        try privateKey.signature(for: signingInput).rawRepresentation.base64UrlEncodedString()
      }
  }

  /// The `htu` claim is the request URI without query or fragment (RFC 9449 §4.2).
  private static func htu(for endpoint: URL) -> String {
    guard var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: true) else {
      return endpoint.absoluteString
    }

    components.query = nil
    components.fragment = nil
    return components.url?.absoluteString ?? endpoint.absoluteString
  }
}
