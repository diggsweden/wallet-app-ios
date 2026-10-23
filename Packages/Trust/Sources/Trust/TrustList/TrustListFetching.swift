// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

protocol TrustListFetching: Sendable {
  func fetch(from url: URL) async throws -> LoteResponse
}
