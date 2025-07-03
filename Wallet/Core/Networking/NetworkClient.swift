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

final class NetworkClient {
  static let shared = NetworkClient()

  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  private init() {}

  private func makeHeaders(
    contentType: String?,
    accept: String?,
    token: String?
  ) -> [String: String] {
    return [
      "Content-Type": contentType,
      "Accept": accept,
      "Authorization": token.map { "Bearer \($0)" },
    ]
    .compactMapValues { $0 }
  }

  private func sendRequest(
    _ url: URL,
    method: HTTPMethod = .get,
    contentType: String? = nil,
    accept: String? = nil,
    token: String? = nil,
    body: (any Encodable)? = nil
  ) async throws -> (Data, HTTPURLResponse) {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = makeHeaders(
      contentType: contentType,
      accept: accept,
      token: token
    )

    if let body {
      do {
        request.httpBody = try encoder.encode(body)
      } catch {
        throw HTTPError.encodingError(error)
      }
    }

    let (data, response): (Data, URLResponse)
    do {
      (data, response) = try await URLSession.shared.data(for: request)
    } catch {
      throw HTTPError.networkError(error)
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      throw HTTPError.invalidResponse
    }

    switch httpResponse.statusCode {
      case 200 ... 299:
        break
      case 401:
        throw HTTPError.unauthorized
      case 403:
        throw HTTPError.forbidden
      case 404:
        throw HTTPError.notFound
      case 500 ... 599:
        throw HTTPError.serverError(httpResponse.statusCode)
      default:
        throw HTTPError.serverError(httpResponse.statusCode)
    }

    return (data, httpResponse)
  }

  func fetchData(
    _ url: URL,
    method: HTTPMethod = .get,
    contentType: String? = nil,
    accept: String? = nil,
    token: String? = nil,
    body: (any Encodable)? = nil
  ) async throws -> (Data, HTTPURLResponse) {
    return try await sendRequest(
      url,
      method: method,
      contentType: contentType,
      accept: accept,
      token: token,
      body: body
    )
  }

  func fetchJSON(
    _ url: URL,
    method: HTTPMethod = .get,
    contentType: String? = nil,
    accept: String? = nil,
    token: String? = nil,
    body: (any Encodable)? = nil
  ) async throws -> JSON {
    let (data, _) = try await sendRequest(
      url,
      method: method,
      contentType: "application/json",
      accept: "application/json",
      token: token,
      body: body
    )

    do {
      return try JSON(data: data)
    } catch {
      throw HTTPError.decodingError(error)
    }
  }

  func fetch<T: Decodable>(
    _ url: URL,
    method: HTTPMethod = .get,
    token: String? = nil,
    body: (any Encodable)? = nil
  ) async throws -> T {
    let (data, _) = try await sendRequest(
      url,
      method: method,
      contentType: "application/json",
      accept: "application/json",
      token: token,
      body: body
    )

    do {
      return try decoder.decode(T.self, from: data)
    } catch {
      throw HTTPError.decodingError(error)
    }
  }
}
