// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public protocol TrustStoreInterface: Sendable {
  func getTrustAnchors(for serviceType: String) async throws -> [SecCertificate]
}
