// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public enum HTTPError: LocalizedError {
  case http(response: HTTPURLResponse, body: Data?)
  case invalidResponse(url: URL?)
  case missingMimeType

  public var errorDescription: String? {
    switch self {
      case .http(let response, _):
        "Server error with status code: \(response.statusCode)"

      case .invalidResponse:
        "Invalid response from server"

      case .missingMimeType:
        "Couldn't extract mime type from http resposne"
    }
  }
}
