// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import OpenID4VCI

extension IdentityAndAccessManagementMetadata {
  var supportsDpop: Bool {
    dpopSigningAlgValuesSupported?
      .contains { $0.name == JWSAlgorithm.AlgorithmType.ES256.rawValue } ?? false
  }
}
