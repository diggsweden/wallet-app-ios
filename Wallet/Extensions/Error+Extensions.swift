import Foundation

extension Error {
  var message: String {
    return (self as? LocalizedError)?.errorDescription ?? self.localizedDescription
  }

  func toErrorEvent() -> ErrorEvent {
    return .init(self.message)
  }
}
