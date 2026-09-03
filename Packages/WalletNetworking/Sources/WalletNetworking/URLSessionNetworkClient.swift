// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public struct URLSessionNetworkClient: NetworkClient {
  private let transport: any HTTPTransport

  public init() {
    self.init(transport: URLSession.shared)
  }

  init(transport: any HTTPTransport) {
    self.transport = transport
  }

  /// Sends the request, retrying once with the server's nonce on a
  /// `use_dpop_nonce` challenge (RFC 9449 §8).
  public func send(_ request: NetworkRequest) async throws -> Data {
    do {
      return try await attempt(request, dpopNonce: nil)
    } catch let error as HTTPError {
      guard case .dpop? = request.authorization, let dpopNonce = error.dpopNonceChallenge else {
        throw error
      }

      return try await attempt(request, dpopNonce: dpopNonce)
    }
  }

  private func attempt(_ request: NetworkRequest, dpopNonce: String?) async throws -> Data {
    let url = request.url
    let urlRequest = try await request.urlRequest(dpopNonce: dpopNonce)

    let (data, response): (Data, URLResponse)
    do {
      (data, response) = try await transport.data(for: urlRequest)
    } catch {
      throw HTTPError.transport(underlying: error, url: url)
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      throw HTTPError.invalidResponse(url: url)
    }

    guard 200 ... 299 ~= httpResponse.statusCode else {
      throw HTTPError.http(response: httpResponse, body: data)
    }

    return data
  }
}
