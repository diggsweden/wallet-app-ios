// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum JWTError: Error {
  case invalidFormat
  case invalidBase64
  case invalidSigner
  case invalidEncrypter
  case invalidDecrypter
  case invalidJWE
}
