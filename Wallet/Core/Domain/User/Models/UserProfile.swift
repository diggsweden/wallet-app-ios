struct UserProfile: Codable, Sendable {
  let email: String
  let pin: String
  let phoneNumber: String?
}
