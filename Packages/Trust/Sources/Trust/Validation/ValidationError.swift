// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public enum ValidationError: LocalizedError, Equatable {
  case trustCreationFailed(OSStatus)
  case evaluationFailed
  case noPublicKey
  case emptyTrustAnchors
  case emptyCertificateChain
  case invalidCertificate
}
