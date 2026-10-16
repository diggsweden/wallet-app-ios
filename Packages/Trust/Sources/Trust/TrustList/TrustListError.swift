// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum TrustListError: LocalizedError {
  case http(response: HTTPURLResponse, body: Data?)
  case invalidResponse(url: URL?)
  case unsupportedContentType(String?)
  case invalidEncoding

  var errorDescription: String? {
    switch self {
      case .http(let response, _):
        "Server error with status code: \(response.statusCode)"

      case .invalidResponse:
        "Invalid response from server"

      case .unsupportedContentType(let mimeType):
        "Unsupported content type: \(mimeType ?? "none")"

      case .invalidEncoding:
        "Trusted list is not valid UTF-8"
    }
  }
}
