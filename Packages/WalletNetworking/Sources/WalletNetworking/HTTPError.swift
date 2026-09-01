// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum HTTPError: LocalizedError {
  case http(response: HTTPURLResponse, body: Data?)
  case transport(underlying: Error, url: URL?)
  case decoding(underlying: Error, url: URL?)
  case invalidResponse(url: URL?)

  var errorDescription: String? {
    switch self {
      case .http(let response, _):
        "Server error with status code: \(response.statusCode)"

      case .transport(let error, _):
        "Network error: \(error.localizedDescription)"

      case .decoding(let error, _):
        "Failed to decode response: \(error.localizedDescription)"

      case .invalidResponse:
        "Invalid response from server"
    }
  }
}
