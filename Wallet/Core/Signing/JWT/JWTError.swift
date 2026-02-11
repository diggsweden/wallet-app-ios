// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
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
