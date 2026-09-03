// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import WalletNetworking

public actor FakeNetworkClient: NetworkClient {
  public typealias Handler = @Sendable (NetworkRequest) async throws -> Data

  public private(set) var requests: [NetworkRequest] = []

  private let handler: Handler

  public init(handler: @escaping Handler) {
    self.handler = handler
  }

  /// Answers every request with the same body, e.g. a JSON document or a compact JWT.
  public init(body: String) {
    self.init { _ in Data(body.utf8) }
  }

  public init(error: any Error & Sendable) {
    self.init { _ in throw error }
  }

  public var lastRequest: NetworkRequest? {
    requests.last
  }

  public func send(_ request: NetworkRequest) async throws -> Data {
    requests.append(request)
    return try await handler(request)
  }
}
