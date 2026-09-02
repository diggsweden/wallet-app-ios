// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public protocol NetworkClient: Sendable {
  func send(_ request: NetworkRequest) async throws -> Data
}

private let snakeCaseDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  return decoder
}()

extension NetworkClient {
  public func fetch<T: Decodable>(
    _ url: URL,
    method: HTTPMethod = .get,
    contentType: String? = "application/json",
    accept: String? = "application/json",
    authorization: RequestAuthorization? = nil,
    body: Data? = nil,
  ) async throws -> T {
    let data = try await send(
      NetworkRequest(
        url: url,
        method: method,
        contentType: contentType,
        accept: accept,
        authorization: authorization,
        body: body,
      )
    )

    do {
      return try snakeCaseDecoder.decode(T.self, from: data)
    } catch {
      throw HTTPError.decoding(underlying: error, url: url)
    }
  }

  public func fetchJwt(
    _ url: URL,
    method: HTTPMethod = .get,
    contentType: String? = "application/jwt",
    accept: String? = "application/jwt",
    authorization: RequestAuthorization? = nil,
    body: Data? = nil,
  ) async throws -> String {
    let data = try await send(
      NetworkRequest(
        url: url,
        method: method,
        contentType: contentType,
        accept: accept,
        authorization: authorization,
        body: body,
      )
    )

    guard let string = String(bytes: data, encoding: .utf8) else {
      throw HTTPError.decoding(underlying: URLError(.badServerResponse), url: url)
    }
    return string
  }
}
