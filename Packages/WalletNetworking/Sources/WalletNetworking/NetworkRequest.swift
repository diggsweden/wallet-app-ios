// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public struct NetworkRequest: Sendable {
  public let url: URL
  public let method: HTTPMethod
  public let contentType: String?
  public let accept: String?
  public let authorization: RequestAuthorization?
  public let body: Data?

  public init(
    url: URL,
    method: HTTPMethod = .get,
    contentType: String? = nil,
    accept: String? = nil,
    authorization: RequestAuthorization? = nil,
    body: Data? = nil,
  ) {
    self.url = url
    self.method = method
    self.contentType = contentType
    self.accept = accept
    self.authorization = authorization
    self.body = body
  }

  func urlRequest(dpopNonce: String?) async throws -> URLRequest {
    var headers = [
      "Content-Type": contentType,
      "Accept": accept,
    ]
    .compactMapValues { $0 }

    if let authorization {
      let authorizationHeaders = try await authorization.headers(
        endpoint: url,
        method: method,
        dpopNonce: dpopNonce,
      )
      headers.merge(authorizationHeaders) { _, new in new }
    }

    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = headers
    request.httpBody = body

    return request
  }
}
