// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

protocol AccountIdProvider: Sendable {
  func accountId() async -> String?
}

struct NilAccountIdProvider: AccountIdProvider {
  func accountId() -> String? { nil }
}
