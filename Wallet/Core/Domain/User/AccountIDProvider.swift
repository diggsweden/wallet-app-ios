protocol AccountIDProvider: Sendable {
  func accountID() async -> String?
}

struct NilAccountIDProvider: AccountIDProvider {
  func accountID() async -> String? { nil }
}
