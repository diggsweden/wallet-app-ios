import Foundation

struct RedirectUrl: Decodable {
  let redirectUri: String
}

struct DisclosureSelection: Identifiable {
  let id = UUID()
  let disclosure: Disclosure
  var isSelected: Bool = true
}
