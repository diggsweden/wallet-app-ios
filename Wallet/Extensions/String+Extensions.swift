import Foundation

extension String {
  var utf8Data: Data {
    // swift-format-ignore
    return self.data(using: .utf8)!
  }
}
