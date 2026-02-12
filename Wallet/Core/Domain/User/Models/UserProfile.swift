// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

struct UserProfile: Codable, Sendable {
  let email: String
  let pin: String
  let phoneNumber: String?
}
