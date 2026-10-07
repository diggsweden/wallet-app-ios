// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum QRScanError: LocalizedError {
  case unsupportedCode
  case openingFailed

  var errorDescription: String? {
    switch self {
      case .unsupportedCode:
        "Den skannade QR-koden stödjs inte av appen"

      case .openingFailed:
        "Kunde inte öppna QR-kod"
    }
  }
}
