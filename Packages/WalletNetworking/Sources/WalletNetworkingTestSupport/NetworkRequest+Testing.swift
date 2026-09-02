// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import WalletNetworking

extension NetworkRequest {
  /// The body as UTF-8 text, for asserting on JSON or form-encoded payloads.
  public var bodyText: String? {
    body.flatMap { String(bytes: $0, encoding: .utf8) }
  }
}
