// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import X509

extension Certificate {
  public var organizationIdentifier: String? {
    subject
      .joined()
      .first { $0.type == [2, 5, 4, 97] }
      .flatMap { String($0.value) }
  }
}
