import Foundation
import JWTKit
import SiopOpenID4VP

struct PresentationRouter: DeeplinkRouter {
  func route(from url: Foundation.URL) async throws -> Route? {
    guard
      let requestUri = url.queryItemValue(for: "request_uri"),
      let encodedClientId = url.queryItemValue(for: "client_id"),
      let requestUrl = URL(string: requestUri)
    else {
      return nil
    }

    let method = HTTPMethod(from: url.queryItemValue(for: "request_uri_method")) ?? .get

    let jwtData = try await NetworkClient.shared.fetchData(requestUrl, method: method)
    let jwtKeyCollection = JWTKeyCollection()
    let requestObject = try await jwtKeyCollection.unverified(
      jwtData,
      as: UnvalidatedRequestObject.self
    )

    guard
      let uri = requestObject.presentationDefinitionUri,
      let definitionUrl = URL(string: uri)
    else {
      return nil
    }

    let definition: PresentationDefinition = try await NetworkClient.shared.fetch(definitionUrl)
    return .presentation(definition: definition)
  }
}
