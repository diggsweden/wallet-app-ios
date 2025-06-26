import Foundation
import JWTKit
import SiopOpenID4VP

extension PresentationDefinition: @retroactive Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: PresentationDefinition, rhs: PresentationDefinition) -> Bool {
    return lhs.id == rhs.id
  }
}

extension UnvalidatedRequestObject: @retroactive JWTPayload {
  public func verify(using algorithm: some JWTAlgorithm) async throws {}
}
