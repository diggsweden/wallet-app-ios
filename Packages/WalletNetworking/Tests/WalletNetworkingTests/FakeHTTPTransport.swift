// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing

@testable import WalletNetworking

/// Plays back scripted responses in order and remembers every request.
/// Running past the end of the script is a test failure, so a client that
/// makes one request too many cannot pass by accident.
actor FakeHTTPTransport: HTTPTransport {
  enum Scripted: Sendable {
    case response(status: Int, headers: [String: String] = [:], body: Data = Data())
    case nonHttpResponse
    case failure(URLError.Code)
  }

  private(set) var requests: [URLRequest] = []
  private var script: [Scripted]

  init(_ script: [Scripted]) {
    self.script = script
  }

  // swiftlint:disable:next async_without_await
  func data(for request: URLRequest) async throws -> (Data, URLResponse) {
    requests.append(request)

    guard !script.isEmpty else {
      Issue.record("unexpected request #\(requests.count) to \(request.url?.absoluteString ?? "-")")
      throw URLError(.unknown)
    }

    switch script.removeFirst() {
      case .response(let status, let headers, let body):
        guard
          let url = request.url,
          let response = HTTPURLResponse(
            url: url,
            statusCode: status,
            httpVersion: nil,
            headerFields: headers,
          )
        else {
          throw URLError(.badServerResponse)
        }
        return (body, response)

      case .nonHttpResponse:
        return (Data(), URLResponse())

      case .failure(let code):
        throw URLError(code)
    }
  }
}
