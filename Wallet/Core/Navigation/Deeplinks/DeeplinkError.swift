// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

enum DeeplinkError: Error {
  case invalidScheme
  case routingFailure(routerName: String, reason: String)
}
