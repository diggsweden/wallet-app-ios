// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import HTTPTypes
import OpenAPIRuntime

struct AuthenticationMiddleware: ClientMiddleware {
  let sessionManager: SessionManager

  func intercept(
    _ request: HTTPRequest,
    body: HTTPBody?,
    baseURL: URL,
    operationID: String,
    next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
  ) async throws -> (
    HTTPResponse,
    HTTPBody?
  ) {
    if operationID == "createAccount" {
      return try await next(request, body, baseURL)
    }

    var request = request

    let token = try await sessionManager.getToken()
    request.setHeader("session", token)

    let (response, body) = try await next(request, body, baseURL)

    if response.status.code == 403 {
      await sessionManager.reset()
    }

    return (response, body)
  }
}
