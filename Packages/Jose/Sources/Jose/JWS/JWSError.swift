// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2ˆ

import Foundation

enum JwsError: LocalizedError {
  case noCertificateChain
  case invalidCertificate

  var errorDescription: String? {
    switch self {
      case .noCertificateChain:
        "There was no certificate chain provided with the JWS"

      case .invalidCertificate:
        "The JWS certificate was invalid"
    }
  }
}
