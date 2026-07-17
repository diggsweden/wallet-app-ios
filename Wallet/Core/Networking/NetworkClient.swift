// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftyJSON

enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"

  init?(from string: String?) {
    guard let string else {
      return nil
    }
    self.init(rawValue: string.uppercased())
  }
}

enum NetworkClient {
  private static let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  private static func makeHeaders(
    contentType: String?,
    accept: String?,
    token: String?
  ) -> [String: String] {
    [
      "Content-Type": contentType,
      "Accept": accept,
      "Authorization": token.map { "Bearer \($0)" },
    ]
    .compactMapValues { $0 }
  }

  private static func sendRequest(
    _ url: URL,
    method: HTTPMethod = .get,
    contentType: String? = nil,
    accept: String? = nil,
    token: String? = nil,
    body: Data? = nil
  ) async throws -> Data {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = makeHeaders(
      contentType: contentType,
      accept: accept,
      token: token
    )
    request.httpBody = body

    let (data, response): (Data, URLResponse)
    do {
      (data, response) = try await URLSession.shared.data(for: request)
    } catch {
      throw HTTPError.transport(underlying: error, url: url)
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      throw HTTPError.invalidResponse(url: url)
    }

    guard 200 ... 299 ~= httpResponse.statusCode else {
      throw HTTPError.http(status: httpResponse.statusCode, url: url, body: data)
    }

    return data
  }

  static func fetch<T: Decodable>(
    _ url: URL,
    method: HTTPMethod = .get,
    contentType: String? = "application/json",
    accept: String? = "application/json",
    token: String? = nil,
    body: Data? = nil
  ) async throws -> T {
    let data = try await sendRequest(
      url,
      method: method,
      contentType: contentType,
      accept: accept,
      token: token,
      body: body
    )

    do {
      return try decoder.decode(T.self, from: data)
    } catch {
      throw HTTPError.decoding(underlying: error, url: url)
    }
  }

  static func fetchJwt(
    _ url: URL,
    method: HTTPMethod = .get,
    contentType: String? = "application/jwt",
    accept: String? = "application/jwt",
    token: String? = nil,
    body: Data? = nil
  ) async throws -> String {
    let data = try await sendRequest(
      url,
      method: method,
      contentType: contentType,
      accept: accept,
      token: token,
      body: body
    )

    guard let string = String(bytes: data, encoding: .utf8) else {
      throw HTTPError.decoding(underlying: URLError(.badServerResponse), url: url)
    }
    return string
  }
}
