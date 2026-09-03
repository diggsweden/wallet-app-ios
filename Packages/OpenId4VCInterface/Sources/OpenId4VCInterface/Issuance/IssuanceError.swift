// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public enum IssuanceError: LocalizedError, Equatable {
  case invalidAuth
  case invalidCredential
  case issuerNotFound
  case authRequestFailed
  case credentialNotSupported
}
