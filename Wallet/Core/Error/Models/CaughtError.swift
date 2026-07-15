// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import WalletGateway

struct CaughtError: Equatable {
  let code: String?
  let message: String?
  let endpoint: String?
  let traceId: String?
  let occurredAt: Date

  init(_ error: Error, at occurredAt: Date = Date(), file: String = #fileID, line: Int = #line) {
    var code: String?
    var message = error.message
    var endpoint: String?
    var transactionId: String?

    switch error {
      case let error as GatewayError:
        if case .problem(let details) = error {
          code = String(details.status)
          endpoint = details.instance
          transactionId = details.transactionId
        }

      case let error as SessionError:
        if case .problem(let details) = error {
          code = String(details.status)
          endpoint = details.instance
          transactionId = details.transactionId
        }

      case let error as HTTPError:
        if case .http(let status, _, let body) = error {
          code = String(status)
          message = Self.serverMessage(from: body) ?? message
        }
        endpoint = error.url.map(Self.hostPath)

      default:
        break
    }

    self.code = code
    self.message = message
    self.endpoint = endpoint
    self.traceId = transactionId ?? "app-trace - \(file):\(line)"
    self.occurredAt = occurredAt
  }
}

private extension CaughtError {
  static func hostPath(_ url: URL) -> String {
    url.host.map { $0 + url.path } ?? url.path
  }

  static func serverMessage(from body: Data?) -> String? {
    guard
      let body,
      let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any]
    else {
      return nil
    }

    let error = json["error"] as? String
    let description = json["error_description"] as? String
    let message = [error, description].compactMap(\.self).joined(separator: ": ")
    return message.isEmpty ? nil : message
  }
}

private extension HTTPError {
  var url: URL? {
    switch self {
      case .http(_, let url, _),
        .transport(_, let url),
        .decoding(_, let url),
        .invalidResponse(let url):
        url
    }
  }
}
