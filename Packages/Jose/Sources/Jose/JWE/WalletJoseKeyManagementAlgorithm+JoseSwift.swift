// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import JSONWebAlgorithms

extension WalletJoseKeyManagementAlgorithm {
  init(_ algorithm: KeyManagementAlgorithm) {
    self = WalletJoseKeyManagementAlgorithm(rawValue: algorithm.rawValue) ?? .ecdhES
  }

  var joseAlgorithm: KeyManagementAlgorithm {
    KeyManagementAlgorithm(rawValue: rawValue) ?? .ecdhES
  }
}
