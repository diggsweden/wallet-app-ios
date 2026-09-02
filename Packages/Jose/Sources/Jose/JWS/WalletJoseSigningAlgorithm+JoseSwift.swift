// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import JSONWebAlgorithms

extension WalletJoseSigningAlgorithm {
  init(_ algorithm: SigningAlgorithm) {
    self = WalletJoseSigningAlgorithm(rawValue: algorithm.rawValue) ?? .invalid
  }

  var joseSigningAlgorithm: SigningAlgorithm {
    SigningAlgorithm(rawValue: rawValue) ?? .invalid
  }
}
