// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

protocol AccountIDProvider: Sendable {
  func accountID() async -> String?
}

struct NilAccountIDProvider: AccountIDProvider {
  func accountID() async -> String? { nil }
}
