// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct NetworkRequest {
  let url: URL
  let method: HTTPMethod
  let contentType: String?
  let accept: String?
  let authorization: RequestAuthorization?
  let body: Data?

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
