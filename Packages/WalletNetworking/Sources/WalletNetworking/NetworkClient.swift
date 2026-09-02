// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

// TODO: Add protocol and conform
public enum NetworkClient {
  private static let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  /// Sends the request, retrying once with the server's nonce on a
  /// `use_dpop_nonce` challenge (RFC 9449 §8).
  private static func sendRequest(
    _ url: URL,
    method: HTTPMethod = .get,
    contentType: String? = nil,
    accept: String? = nil,
    authorization: RequestAuthorization? = nil,
    body: Data? = nil,
  ) async throws -> Data {
    let request = NetworkRequest(
      url: url,
      method: method,
      contentType: contentType,
      accept: accept,
      authorization: authorization,
      body: body,
    )

    do {
      return try await attempt(request, dpopNonce: nil)
    } catch let error as HTTPError {
      guard case .dpop? = authorization, let dpopNonce = error.dpopNonceChallenge else {
        throw error
      }

      return try await attempt(request, dpopNonce: dpopNonce)
    }
  }

  private static func attempt(_ request: NetworkRequest, dpopNonce: String?) async throws -> Data {
    let url = request.url
    let urlRequest = try await request.urlRequest(dpopNonce: dpopNonce)

    let (data, response): (Data, URLResponse)
    do {
      (data, response) = try await URLSession.shared.data(for: urlRequest)
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

  public static func fetch<T: Decodable>(
    _ url: URL,
    method: HTTPMethod = .get,
    contentType: String? = "application/json",
    accept: String? = "application/json",
    authorization: RequestAuthorization? = nil,
    body: Data? = nil,
  ) async throws -> T {
    let data = try await sendRequest(
      url,
      method: method,
      contentType: contentType,
      accept: accept,
      authorization: authorization,
      body: body,
    )

    do {
      return try decoder.decode(T.self, from: data)
    } catch {
      throw HTTPError.decoding(underlying: error, url: url)
    }
  }

  public static func fetchJwt(
    _ url: URL,
    method: HTTPMethod = .get,
    contentType: String? = "application/jwt",
    accept: String? = "application/jwt",
    authorization: RequestAuthorization? = nil,
    body: Data? = nil,
  ) async throws -> String {
    let data = try await sendRequest(
      url,
      method: method,
      contentType: contentType,
      accept: accept,
      authorization: authorization,
      body: body,
    )

    guard let string = String(bytes: data, encoding: .utf8) else {
      throw HTTPError.decoding(underlying: URLError(.badServerResponse), url: url)
    }
    return string
  }
}
