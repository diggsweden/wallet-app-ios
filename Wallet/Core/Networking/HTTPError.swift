// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

enum HTTPError: Error {
  case invalidResponse
  case unauthorized
  case forbidden
  case notFound
  case serverError(Int)
  case decodingError(Error)
  case encodingError(Error)
  case networkError(Error)

  var localizedDescription: String {
    switch self {
      case .invalidResponse:
        return "Invalid response from server"
      case .unauthorized:
        return "Unauthorized access"
      case .forbidden:
        return "Access forbidden"
      case .notFound:
        return "Resource not found"
      case .serverError(let code):
        return "Server error with status code: \(code)"
      case .decodingError(let error):
        return "Failed to decode response: \(error.localizedDescription)"
      case .encodingError(let error):
        return "Failed to encode body: \(error.localizedDescription)"
      case .networkError(let error):
        return "Network error: \(error.localizedDescription)"
    }
  }
}
