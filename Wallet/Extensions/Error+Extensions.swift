import Foundation

extension Error {
  var message: String {
    return (self as? LocalizedError)?.errorDescription ?? self.localizedDescription
  }
}
