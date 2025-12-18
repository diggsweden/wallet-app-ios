import Foundation
import HTTPTypes

extension HTTPRequest {
  mutating func setHeader(_ key: String, _ value: String) {
    guard let keyField = HTTPField.Name(key) else {
      return
    }

    headerFields[keyField] = value
  }
}
