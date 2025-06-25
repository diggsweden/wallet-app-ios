import Foundation

enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
}

final class NetworkClient {
  static let shared = NetworkClient()
  
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  
  private init() {}
  
  func fetch<T: Decodable>(
    _ url: URL,
    method: HTTPMethod = .get,
    token: String? = nil,
    body: (any Encodable)? = nil
  ) async throws -> T {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    if let token {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
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
    case 200...299:
      break
    case 401:
      throw HTTPError.unauthorized
    case 403:
      throw HTTPError.forbidden
    case 404:
      throw HTTPError.notFound
    case 500...599:
      throw HTTPError.serverError(httpResponse.statusCode)
    default:
      throw HTTPError.serverError(httpResponse.statusCode)
    }
    
    do {
      return try decoder.decode(T.self, from: data)
    } catch {
      throw HTTPError.decodingError(error)
    }
  }
}
