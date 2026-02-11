// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

enum DeeplinkError: Error {
  case invalidScheme
  case routingFailure(routerName: String, reason: String)
}
