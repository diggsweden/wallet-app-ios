// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import JSONWebAlgorithms

extension WalletJoseContentEncryptionAlgorithm {
  init(_ algorithm: ContentEncryptionAlgorithm) {
    self = WalletJoseContentEncryptionAlgorithm(rawValue: algorithm.rawValue) ?? .a128GCM
  }

  var joseAlgorithm: ContentEncryptionAlgorithm {
    ContentEncryptionAlgorithm(rawValue: rawValue) ?? .a128GCM
  }
}
