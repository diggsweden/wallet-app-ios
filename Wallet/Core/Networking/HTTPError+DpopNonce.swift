// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

extension HTTPError {
  private static let nonceErrorCode = "use_dpop_nonce"

  /// The nonce to repeat the request with, if this error is a `use_dpop_nonce`
  /// challenge.
  var dpopNonceChallenge: String? {
    guard
      case .http(let response, let body) = self,
      400 ..< 500 ~= response.statusCode,
      Self.isNonceChallenge(response: response) || Self.isNonceChallenge(body: body)
    else {
      return nil
    }

    return response.value(forHTTPHeaderField: "DPoP-Nonce")
  }

  private static func isNonceChallenge(response: HTTPURLResponse) -> Bool {
    guard let challenge = response.value(forHTTPHeaderField: "WWW-Authenticate") else {
      return false
    }

    return challenge.localizedCaseInsensitiveContains("DPoP")
      && challenge.localizedCaseInsensitiveContains("error=\"\(nonceErrorCode)\"")
  }

  private static func isNonceChallenge(body: Data?) -> Bool {
    guard
      let body,
      let response = try? JSONDecoder().decode(ErrorResponse.self, from: body)
    else {
      return false
    }

    return response.error == nonceErrorCode
  }

  /// An OAuth error response (RFC 6749 §5.2).
  private struct ErrorResponse: Decodable {
    let error: String
  }
}
