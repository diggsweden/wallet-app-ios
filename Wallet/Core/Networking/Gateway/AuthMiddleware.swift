import Foundation
import HTTPTypes
import OpenAPIRuntime

struct AuthenticationMiddleware: ClientMiddleware {
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

    if let name = HTTPField.Name("X-API-KEY") {
      request.headerFields[name] = "my_secret_key"
    }

    return try await next(request, body, baseURL)
  }
}
