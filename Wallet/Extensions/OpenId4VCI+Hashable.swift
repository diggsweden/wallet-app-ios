import Foundation
import OpenID4VCI

extension Claim: @retroactive Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(path)
  }

  public static func == (
    lhs: Claim,
    rhs: Claim
  ) -> Bool {
    return lhs.path == rhs.path
  }
}

extension Display: @retroactive Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }

  public static func == (
    lhs: Display,
    rhs: Display
  ) -> Bool {
    return lhs.name == rhs.name
  }
}
