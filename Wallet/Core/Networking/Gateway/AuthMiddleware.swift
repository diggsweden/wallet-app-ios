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
    var request = request

    if operationID == "createAccount" {
      request.setHeader("X-API-KEY", AppConfig.apiKey)
      return try await next(request, body, baseURL)
    }

    let token = try await sessionManager.getToken()
    request.setHeader("session", token)

    let (response, body) = try await next(request, body, baseURL)

    if response.status.code == 403 {
      await sessionManager.reset()
    }

    return (response, body)
  }
}
