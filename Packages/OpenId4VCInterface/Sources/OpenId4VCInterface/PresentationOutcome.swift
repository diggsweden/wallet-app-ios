// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public struct PresentationOutcome: Sendable {
  public let redirectUrl: URL?

  public init(redirectUrl: URL?) {
    self.redirectUrl = redirectUrl
  }
}
