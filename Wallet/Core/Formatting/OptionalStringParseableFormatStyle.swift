import Foundation

struct OptionalStringParseableFormatStyle: ParseableFormatStyle {
  var parseStrategy: Strategy = .init()

  func format(_ value: String?) -> String {
    value ?? ""
  }

  struct Strategy: ParseStrategy {
    func parse(_ value: String) throws -> String? {
      guard !value.isEmpty else {
        return nil
      }
      return value
    }
  }
}

extension ParseableFormatStyle where Self == OptionalStringParseableFormatStyle {
  static var optional: OptionalStringParseableFormatStyle { .init() }
}
