// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

struct UserProfile: Codable, Sendable {
  let email: String
  let pin: String
  let phoneNumber: String?
}
