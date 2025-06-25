import Foundation

extension URL {
  func queryItemValue(for key: String) -> String? {
    return URLComponents(url: self, resolvingAgainstBaseURL: false)?
      .queryItems?
      .first { $0.name == key }?
      .value
  }
}
