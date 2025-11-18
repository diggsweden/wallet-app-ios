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
      request.setHeader("X-API-KEY", "my_secret_key")
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
