import Foundation
import JWTKit
import SiopOpenID4VP

struct PresentationRouter: DeeplinkRouter {
  func route(from url: Foundation.URL) async throws -> Route {
    guard
      let requestUri = url.queryItemValue(for: "request_uri"),
      let encodedClientId = url.queryItemValue(for: "client_id"),
      let requestUrl = URL(string: requestUri)
    else {
      throw routingFailure("request_uri was missing or is invalid")
    }

    let method = HTTPMethod(from: url.queryItemValue(for: "request_uri_method")) ?? .get

    let (jwtData, response) = try await NetworkClient.shared.fetchData(requestUrl, method: method)

    guard response.value(forHTTPHeaderField: "Content-Type") == "application/oauth-authz-req+jwt"
    else {
      throw routingFailure("Invalid content-type header (expected oauth-authz-req+jwt)")
    }
    
    let json = try await NetworkClient.shared.fetchJSON(requestUrl, method: method)
    let jwtKeyCollection = JWTKeyCollection()
    let requestObject = try await jwtKeyCollection.unverified(
      jwtData,
      as: UnvalidatedRequestObject.self
    )

    guard
      let uri = requestObject.presentationDefinitionUri,
      let definitionUrl = URL(string: uri)
    else {
      throw routingFailure("Failed parsing presentation definition URI")
    }

    let definition: PresentationDefinition = try await NetworkClient.shared.fetch(definitionUrl)
    return .presentation(definition: definition)
  }
}
