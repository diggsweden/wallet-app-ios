// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum JwsError: LocalizedError, Equatable {
  case noCertificateChain
  case invalidCertificate
  case unexpectedType(expected: String, actual: String?)

  var errorDescription: String? {
    switch self {
      case .noCertificateChain:
        "There was no certificate chain provided with the JWS"

      case .invalidCertificate:
        "The JWS certificate was invalid"

      case let .unexpectedType(expected, actual):
        "Expected JWS type \(expected) but got \(actual ?? "none")"
    }
  }
}
