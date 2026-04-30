// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public protocol AccountIdProvider: Sendable {
  func accountId() async -> String?
}

public struct NilAccountIdProvider: AccountIdProvider {
  public init() {}
  public func accountId() async -> String? { nil }
}
