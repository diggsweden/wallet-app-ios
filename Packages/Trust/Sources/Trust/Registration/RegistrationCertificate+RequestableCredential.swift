// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenId4VCInterface

extension RegistrationCertificate {
  public var requestableCredentials: [RequestableCredential] {
    credentials.map { credential in
      RequestableCredential(
        format: credential.format,
        vctValues: Set(credential.meta.vctValues),
        claimPaths: Set(credential.claim.map(\.path)),
      )
    }
  }
}
