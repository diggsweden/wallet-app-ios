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
      if let name = HTTPField.Name("X-API-KEY") {
        request.headerFields[name] = "my_secret_key"
      }
      return try await next(request, body, baseURL)
    }

    if let name = HTTPField.Name("Cookie") {
      let token = try await sessionManager.getToken()
      request.headerFields[name] = "JSESSIONID=\(token)"
    }

    return try await next(request, body, baseURL)
  }
}
