// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct PresentationRouter: DeeplinkRouter {
  func route(from url: Foundation.URL) throws -> Route {
    .presentation(url: url)
  }
}
